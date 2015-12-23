#
#  Be sure to run `pod spec lint RNCryptor.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
s.name      = 'RNCryptor'
s.version   = '1.2'
s.license  = 'MIT'
s.platform  = :ios
s.summary   = 'CCCryptor (AES encryption) wrappers for iOS and Mac'
s.description = 'CCCryptor (AES encryption) wrappers for iOS and Mac'
s.homepage  = 'https://github.com/rnapier/RNCryptor'
s.author    = { 'bsorrentino' =>  ' bartolomeo.sorrentino@gmail.com' }
s.source    = { :git => 'https://github.com/rnapier/RNCryptor.git', :commit => 'a0a29e4341ea643a83fb180b74fac5e5d234d97b' }
s.source_files = 'RNCryptor/*.{h,m}'
#s.resources = "*.png", "en.lproj/*.xib"
s.frameworks = 'Security'
s.exclude_files = "RNCryptor.xcodeproj", "RNCryptorTests", "README.md", "test.enc", "AppledocSettings.plist"
s.requires_arc = true

end
