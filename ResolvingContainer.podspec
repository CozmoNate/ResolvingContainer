Pod::Spec.new do |s|
  s.name             = 'ResolvingContainer'
  s.version          = '1.0.3'
  s.summary          = 'IOC resolving container implemented in Swift'
  s.homepage         = 'https://github.com/kzlekk/ResolvingContainer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Natan Zalkin' => 'natan.zalkin@me.com' }
  s.source           = { :git => 'https://kzlekk@github.com/kzlekk/ResolvingContainer.git', :tag => "#{s.version}" }
  s.module_name      = 'ResolvingContainer'
  s.swift_version    = '5.0'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '10.0'

  s.source_files = 'ResolvingContainer/*.swift'

end
