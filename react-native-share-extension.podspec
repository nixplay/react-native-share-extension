Pod::Spec.new do |s|
	s.name         = "react-native-share-extension"
	s.version      = "2.1.1"
	s.license      = "MIT"
	s.homepage     = "https://github.com/nixplay/react-native-share-extension"
	s.authors      = { 'James Kong' => 'james.kong@nixplay.com' }
	s.summary      = "This is a helper module which brings react native as an engine to drive share extension for your app."
	s.source       = { :git => "https://github.com/nixplay/react-native-share-extension.git" }
	s.source_files  = "ios/*.{h,m}"

	s.platform     = :ios, "9.0"
  end
