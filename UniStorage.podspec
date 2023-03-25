Pod::Spec.new do |s|
  s.name             = 'UniStorage'
  s.version          = '0.0.1'
  s.summary          = 'Setting Storage Library Using MMKV'
  s.homepage         = 'https://github.com/felikslv01/UniStorage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'felikslv' => 'felikslv@163.com' }
  s.source           = { :git => 'https://github.com/felikslv01/UniStorage.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  
  s.prefix_header_file = false
  s.source_files = [
    'Sources/**/*.{swift,h,m,mm}',
    'UniStorage.swift'
  ]
  s.dependency 'MMKV'
end
