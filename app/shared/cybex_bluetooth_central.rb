class Characteristic
  attr_reader :cb_characteristic

  def initialize(cb_characteristic)
    @cb_characteristic = cb_characteristic
  end

  def to_i
    integer_value = 0
    bytes = cb_characteristic.value.length.times.map do |place|
      cb_characteristic.value.bytes[place]
    end

    bytes.each_with_index do |byte, index|
      integer_value += (256 ** index) * byte
    end

    integer_value
  end

  def key
    CybexBluetoothCentral::METRICS_CHARACTERISTICS[cb_characteristic.UUID]
  end
end

class CybexBluetoothCentral
  WORKOUT_SERVICE_UUID = CBUUID.UUIDWithString('1CA931A8-6A77-4E4D-AAD8-5CA168163BA6')

  METRICS_CHARACTERISTICS = {
    elapsed_seconds:    CBUUID.UUIDWithString('1799649B-7C99-48B1-98CF-0B7DCDA597A7'),
    meters_per_hour:    CBUUID.UUIDWithString('B7CF5C63-9C07-40C7-A6AD-6AA6D8ED031D'),
    calories_burned:    CBUUID.UUIDWithString('3D00BEF9-375D-40DE-88DB-F220631BD8A4'),
    calories_per_hour:  CBUUID.UUIDWithString('AC869A9F-9754-44AB-A280-C61B7A6D15BE'),
    meters_travelled:   CBUUID.UUIDWithString('45186DD6-06E7-44A2-A5EA-BC9C45B7E2B5'),
    current_heart_rate: CBUUID.UUIDWithString('C9F0DCBF-DD99-4282-B74B-AC44BB5C013E'),
    strides_per_minute: CBUUID.UUIDWithString('065806B9-7AC6-4DCC-B42C-96BB712E0CEB'),
    current_mets:       CBUUID.UUIDWithString('E4A234EA-DC68-4B07-B435-485B9B3406FD')
  }.invert.freeze

  attr_accessor :values
  attr_accessor :on_found_peripheral
  attr_accessor :on_no_power
  attr_accessor :on_received_characteristic

  def log(msg, tag='')
    #Logger.log msg, tag
    NSLog msg
  end

  def self.start
    instance.start
  end

  def peripherals
    @peripherals ||= []
  end

  def self.instance
    Dispatch.once { @instance = new }
    @instance
  end

  def start
    @manager.stopScan if @manager && @manager.state == CBCentralManagerStatePoweredOn
    peripherals.each do |peripheral|
      @manager.cancelPeripheralConnection peripheral
    end
    @peripherals.clear
    @manager ||= CBCentralManager.alloc.initWithDelegate self, queue: nil
    start_scan @manager
  end

  def centralManagerDidUpdateState(manager)
    start_scan manager
  end

  def start_scan(manager)
    if manager.state == CBCentralManagerStatePoweredOn
      manager.scanForPeripheralsWithServices nil, options: {
        CBCentralManagerScanOptionAllowDuplicatesKey => false
      }
    else
      on_no_power.call if on_no_power
    end
  end


  def centralManager(manager, didDiscoverPeripheral: peripheral, advertisementData: data, RSSI: rssi)
    #if data[CBAdvertisementDataIsConnectable]
      #log "Found peripheral #{peripheral.name}, rssi=#{rssi}, data=#{data}"
      peripherals << peripheral
      peripheral.delegate = self
      manager.connectPeripheral peripheral, options: nil
    #else
    #  log "UNCONNECTABLE PERIPHERAL: #{peripheral.name}, rssi=#{rssi}, data=#{data}"
    #end
  end

  def centralManager(manager, didConnectPeripheral: peripheral)
    peripherals << peripheral
    log "connected to peripheral #{peripheral.UUID.description}, name #{peripheral.name}, services: #{peripheral.services.inspect}"
    peripheral.discoverServices nil #[WORKOUT_SERVICE_UUID]
  end

  def centralManager(manager, didFailToConnectPeripheral: peripheral, error: error)
    log "ERROR connecting to peripheral #{peripheral.UUID}, name #{peripheral.name}, error: #{error}"
  end

  def peripheral(peripheral, didDiscoverServices: error)
    log "Did discover services, error = #{error}, services=#{peripheral.services.inspect}"
    return if error || !peripheral.services
    if peripheral.services.map(&:UUID).include? WORKOUT_SERVICE_UUID
      on_found_peripheral.call(peripheral) if on_found_peripheral
    end

    #peripheral.services.each do |service|
    #  if service.UUID == WORKOUT_SERVICE_UUID
    #    @manager.stopScan
    #    log "discovering characteristics for #{service}, characteristics = #{service.characteristics}"
    #    peripheral.discoverCharacteristics nil, forService: service
    #  end
    #end
  end

  def fetch_characteristics(peripheral)
    peripheral.services.each do |service|
      if service.UUID == WORKOUT_SERVICE_UUID
        log "discovering characteristics for #{service}, characteristics = #{service.characteristics}"
        peripheral.discoverCharacteristics nil, forService: service
      end
    end
  end

  def peripheral(peripheral, didDiscoverCharacteristicsForService: service, error: error)
    log "Discovered characteristics for #{service}, error: #{error}, characteristics = #{service.characteristics}"
    return if error || !service.characteristics

    service.characteristics.each do |characteristic|
      log "FOUND CHARACTERISTIC: #{characteristic.UUID.description}"
      peripheral.setNotifyValue true, forCharacteristic: characteristic
    end
  end

  def peripheral(peripheral, didUpdateNotificationStateForCharacteristic: characteristic, error: err)
    return log "Error changing notification state: #{error.localizedDescription}" if err
    log "Updated notification state for characteristic #{characteristic.UUID.description}"
  end

  def peripheral(peripheral, didUpdateValueForCharacteristic: characteristic, error: err)
    return log "Error updateing value for characteristic: #{error.localizedDescription}" if err

    #s = characteristic.UUID.description
    #@values ||= {}
    #@values[s] = Characteristic.new(characteristic).to_i
    on_received_characteristic.call Characteristic.new(characteristic) if on_received_characteristic
    #log @values.inspect
    #log "characteristic: #{METRICS_CHARACTERISTICS[characteristic.UUID].inspect} => #{@values[s]}"
  end

  def centralManager(manager, didDisconnectPeripheral: peripheral, error: err)
    log "disconnected #{peripheral.services.map &:description if peripheral.services}"
  end
end
