source 'https://github.com/CocoaPods/Specs.git'

platform :ios, :deployment_target => '7.0'

inhibit_all_warnings!

xcodeproj 'Wikipedia'

# Syntax
pod 'blockskit/Core', '~> 2.2'

# Networking and Parsing
pod 'AFNetworking/NSURLConnection', '~> 2.5'
pod 'hpple', '~> 0.2'


# Autolayout Helper
pod 'Masonry', '~> 0.6'

# Color
pod 'UIImage+AverageColor'
pod 'Colours'

# Crash Reporting
pod 'HockeySDK', '3.6.2'

# Experimental
pod 'Tweaks'
pod 'LoremIpsum'

target 'WikipediaUnitTests', :exclusive => true do
  pod 'OCMockito', '~> 1.4'
  pod 'OCHamcrest', '~> 4.1'
  pod 'Expecta', '~> 0.3.0'
end

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    if target.name == "Pods-Tweaks"
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'FB_TWEAK_ENABLED=1']
      end
    end
  end
end
