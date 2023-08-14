# Podfile

# Enable modular headers globally
use_modular_headers!

# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'PlutoController' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks

  pod 'Firebase/Crashlytics'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Realm'

  # Pods for PlutoController

  target 'PlutoControllerTests' do
    inherit! :search_paths
    pod 'Realm/Headers'
    # Pods for testing
  end

  target 'PlutoControllerUITests' do
    inherit! :search_paths
    pod 'Realm/Headers'
    # Pods for testing
  end

end
