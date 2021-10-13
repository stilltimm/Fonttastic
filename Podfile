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

  target 'FonttasticTests' do
    inherit! :search_paths
  end

end

target 'FonttasticKeyboard' do

  default_pods

end
