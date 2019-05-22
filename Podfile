target 'deltachat-ios' do
  platform :ios, '10.0'
  use_frameworks!
  swift_version = '4.2'

  # ignore all warnings from all dependencies
  inhibit_all_warnings!

  pod 'SwiftLint'
  pod 'SwiftFormat/CLI'
  pod 'ALCameraViewController', :git => 'https://github.com/dignifiedquire/ALCameraViewController'
  # pod 'openssl-ios-bitcode'
  pod 'ReachabilitySwift'
  pod 'QuickTableViewController'
  pod 'JGProgressHUD'
  pod 'SwiftyBeaver'
  pod 'DBDebugToolkit'
  pod 'MessageKit'
 
  target 'deltachat-iosTests' do
    inherit! :search_paths
    # Pods for testing
end
end
