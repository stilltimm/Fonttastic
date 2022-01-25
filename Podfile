platform :ios, '14.0'

use_frameworks!
inhibit_all_warnings!

def default_pods

  pod 'Cartography'
  pod 'Purchases'
  pod 'Amplitude-iOS', '~> 4.9.3'

  pod 'SwiftLint', :configurations => ['Debug']
  # pod 'Reveal-SDK', :configurations => ['Debug']

end

target 'Fonttastic' do

  default_pods
  pod 'SVGKit'

end

target 'FonttasticTools' do

  default_pods
  pod 'KeychainAccess'
  pod 'ZIPFoundation', '~> 0.9'

end

target 'FonttasticKeyboard' do

  default_pods

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
