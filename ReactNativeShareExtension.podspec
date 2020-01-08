require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "ReactNativeShareExtension"
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']

  s.authors      = package['author']
  s.homepage     = package['repository']['url']
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '10.0'

  s.source       = { :git => "https://github.com/nixplay/react-native-share-extension.git", :tag => "release/1.2.2" }
  s.source_files  = "ios/**/*.{h,m}"

  s.dependency 'AFNetworking'
  s.dependency 'SDAVAssetExportSession'
	s.dependency 'React'
	s.dependency 'NixNetwork'

end