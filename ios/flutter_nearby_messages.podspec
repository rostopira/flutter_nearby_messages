Pod::Spec.new do |s|
  s.name             = 'flutter_nearby_messages'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Google Nearby Messages library'
  s.description      = <<-DESC
See repository https://github.com/rostopira/flutter_nearby_messages
                       DESC
  s.homepage         = 'https://github.com/rostopira/flutter_nearby_messages'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dima Rostopira' => 'rostopiradv@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  # ***************************
  s.dependency 'NearbyMessages'
  s.preserve_path = 'Classes/NearbyMessages/NearbyMessages.modulemap'
  s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/Classes/NearbyMessages $(PODS_TARGET_SRCROOT)/Classes' }
  # ***************************
  s.static_framework = true
  s.ios.deployment_target = '9.0'
end

