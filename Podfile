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

# Crash Reporting
pod 'HockeySDK', '3.6.2'

# Experimental
pod 'Tweaks'
pod 'LoremIpsum'

target 'WikipediaUnitTests', :exclusive => false do
  pod 'OCMockito', '~> 1.4'
  pod 'OCHamcrest', '~> 4.1'
end
