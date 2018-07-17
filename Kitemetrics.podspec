#
# Be sure to run `pod lib lint Kitemetrics.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Kitemetrics'
  s.version          = '1.1.9'
  s.summary          = 'iOS App Analytics, Apple Search Ads Attribution, and Reporting.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Kitemetrics provides keyword level attribution for Apple Search Ads. It associates each attribution to an In-App Purchase. The Kitemetrics web service calculates the Average Revenue per User.
                       DESC

  s.homepage         = 'https://github.com/kitefaster/kitemetrics_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Kitefaster, LLC' => '' }
  s.source           = { :git => 'https://github.com/kitefaster/kitemetrics_iOS.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/kitefasterApps'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Kitemetrics/Classes/**/*'
  s.weak_framework = 'iAd'
  
end
