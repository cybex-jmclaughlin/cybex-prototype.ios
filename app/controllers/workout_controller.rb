class WorkoutController < UIViewController
  def viewDidLoad
    super
    init_nav

    rmq.stylesheet = WorkoutStylesheet
    rmq(self.view).apply_style :root_view

    rmq.append(UIImageView, :background)
    rmq.append(UILabel, :calories_burned)
    rmq.append(UILabel, :elapsed_seconds)
    rmq.append(UILabel, :strides_per_minute)
    rmq.append(UILabel, :current_heart_rate)
    rmq.append(UILabel, :current_mets)

    @update_characteristic = lambda do |characteristic|
      value = characteristic.to_i
      key = characteristic.key
      NSLog "SET CHARACTERISTIC #{key} => #{value}"

      case key
      when :elapsed_seconds
        value = Duration.seconds(value)
      end

      Dispatch::Queue.main.async do
        rmq(key).attr text: value.to_s
      end
    end

    CybexBluetoothCentral.instance.on_received_characteristic = @update_characteristic
  end

  def dealloc
    if @update_characteristic ==  CybexBluetoothCentral.instance.on_received_characteristic
      CybexBluetoothCentral.instance.on_received_characteristic = nil
    end
    super
  end

  def init_nav
    self.title = 'Connected'
  end

  # Remove if you are only supporting portrait
  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskLandscape
  end

  # Remove if you are only supporting portrait
  def willAnimateRotationToInterfaceOrientation(orientation, duration: duration)
    rmq.all.reapply_styles
  end
end
