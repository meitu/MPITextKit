#
# Be sure to run `pod lib lint MPITextKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MPITextKit'
  s.version          = '0.1.5'
  s.summary          = 'Powerful text framework for iOS to display text based on TextKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://github.com/meitu/MPITextKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tpphha' => 'tpphha@gmail.com' }
  s.source           = { :git => 'https://github.com/meitu/MPITextKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MPITextKit/Classes/**/*.{h,m,mm}'
  s.public_header_files = [
    'MPITextKit/Classes/*.h', 
    'MPITextKit/Classes/Core/*.h', 
    'MPITextKit/Classes/Components/*.h',
    'MPITextKit/Classes/Attributes/*.h', 
    'MPITextKit/Classes/Categories/*.h', 
    'MPITextKit/Classes/Utils/*.h', 
  ]
  # s.resource_bundles = {
  #   'MPITextKit' => ['MPITextKit/Assets/*.png']
  # }

  s.library = 'c++'
  s.frameworks = 'UIKit', 'CoreFoundation','CoreText', 'QuartzCore', 'Accelerate'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
