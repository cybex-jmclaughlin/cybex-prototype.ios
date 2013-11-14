# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'
require 'bundler'
Bundler.require

require 'ruby_motion_query'

Motion::Project::App.setup do |app|

  app.name = 'cybex-prototype'
  app.identifier = 'com.cybexintl.cybex-prototype'
  app.short_version = '0.1.0'
  app.version = app.short_version

  app.sdk_version = '7.0'
  app.deployment_target = '7.0'
  # Or for iOS 6
  #app.sdk_version = '6.1'
  #app.deployment_target = '6.0'

  #app.icons = ["icon.png", "icon-29.png", "icon-40.png", "icon-60.png", "icon-76.png", "icon-512.png"]

  # prerendered_icon is only needed in iOS 6
  #app.prerendered_icon = true

  app.device_family = [:ipad]
  app.interface_orientations = [:landscape_left, :landscape_right]

  app.files += Dir.glob(File.join(app.project_dir, 'lib/**/*.rb'))

  app.codesign_certificate = 'iPhone Developer: Joseph Lind (FJ4HBB2Z8D)'
  app.frameworks << 'CoreBluetooth'
  app.frameworks << 'CFNetwork'
  app.frameworks << 'SystemConfiguration'

  # Use `rake config' to see complete project settings, here are some examples:
  #
  # app.fonts = ['Oswald-Regular.ttf', 'FontAwesome.otf'] # These go in /resources
  # app.frameworks = %w(QuartzCore CoreGraphics MediaPlayer MessageUI CoreData)
  #
  # app.vendor_project('vendor/Flurry', :static)
  # app.vendor_project('vendor/DSLCalendarView', :static, :cflags => '-fobjc-arc') # Using arc
end
