#
# Be sure to run `pod lib lint DRScrollableViews.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DRScrollableViews'
  s.version          = '0.2.6'
  s.summary          = 'UITableView, UICollectionView等的一些特殊效果'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DeanFs/DRScrollableViews'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dean_F' => 'stone.feng1990@gmail.com' }
  s.source           = { :git => 'https://github.com/DeanFs/DRScrollableViews.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.resource = 'DRScrollableViews/Assets/*', 'DRScrollableViews/Classes/**/*.xib'

  s.subspec 'Common' do |ss|
    ss.source_files = 'DRScrollableViews/Classes/Common/*.{h,m}'
  end

  s.subspec 'DRDragSortTableView' do |ss|
    ss.source_files = 'DRScrollableViews/Classes/DRDragSortTableView/*.{h,m}'
    ss.dependency 'DRScrollableViews/Common'
  end

  s.subspec 'DRCollectionViews' do |ss|
    ss.source_files = 'DRScrollableViews/Classes/DRCollectionViews/*.{h,m}'
    ss.dependency 'DRScrollableViews/Common'
  end
  
  # s.resource_bundles = {
  #   'DRScrollableViews' => ['DRScrollableViews/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.dependency 'DRMacroDefines'
  s.dependency 'DRCategories'
  s.dependency 'HexColors', '4.0.0'
  s.dependency 'Masonry'

end
