class MainController < UITableViewController
  attr_reader :devices

  def viewDidLoad
    super

    @devices = []
    init_nav

    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    @central = CybexBluetoothCentral.instance

    refresh_control = UIRefreshControl.new
    refresh_control.addTarget self, action: :scan, forControlEvents: UIControlEventValueChanged
    setRefreshControl refresh_control
  end

  def viewDidAppear(animated)
    super.tap do
      scan
    end
  end

  def init_nav
    self.title = 'Nearby Equipment'

    self.navigationItem.tap do |nav|
      nav.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh,
                                                                           target: self, action: :scan)
    end
  end

  def scan
    Logger.log 'scanning...'
    @devices.clear
    tableView.reloadData
    @central.start
    @central.on_found_peripheral = lambda do |peripheral|
      Logger.log "Found peripheral: #{peripheral}"
      @devices << peripheral
      tableView.reloadData
      refreshControl.endRefreshing
    end

    @central.on_no_power = lambda do
      @devices << 'SIMULATOR'
      tableView.reloadData
    end
  end

  # Remove if you are only supporting portrait
  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskLandscape
  end

  # Remove if you are only supporting portrait
  def willAnimateRotationToInterfaceOrientation(orientation, duration: duration)
    rmq.all.reapply_styles
  end


  #UITableView Methods
  #
  def tableView(tableView, numberOfRowsInSection: section)
    devices.length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier('peripheral') || new_cell
    device = devices[indexPath.row]
    cell.textLabel.text = "#{device.description}"
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    device = devices[indexPath.row]
    Logger.log "selected #{device.description}"
    @central.fetch_characteristics device unless device.kind_of?(String)
    controller = WorkoutController.new
    navigationController.pushViewController controller, animated: true
  end

  def new_cell
    cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: 'peripheral')
  end
end
