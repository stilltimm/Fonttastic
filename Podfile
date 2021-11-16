platform :ios, '14.0'

use_frameworks!
inhibit_all_warnings!

def default_pods

  # UI

  pod 'Cartography'

  # Dev Tools

  pod 'SwiftLint', :configurations => ['Debug']
  pod 'Reveal-SDK', :configurations => ['Debug']

end

target 'Fonttastic' do

  default_pods

  # UI Dependencies

  pod 'SVGKit'

  target 'FonttasticTests' do
    inherit! :search_paths
  end

end

target 'FonttasticToolsStatic' do

  pod 'ZIPFoundation', '~> 0.9'
  pod 'Cartography'

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
