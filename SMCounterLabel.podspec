#
# Be sure to run `pod lib lint SMCounterLabel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SMCounterLabel'
  s.version          = '0.1.1'
  s.summary          = 'Animated UILabel subclass.'
  s.swift_version    = '4.2'

  s.description      = 'A numeric label that animates value change with a stock-like animation'

  s.homepage         = 'https://github.com/slavenko/SMCounterLabel'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'slavenko' => 'slavenko.miljic@gmail.com' }
  s.source           = { :git => 'https://github.com/slavenko/SMCounterLabel.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'SMCounterLabel/Classes/**/*'
end
