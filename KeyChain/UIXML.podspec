#
#  Be sure to run `pod spec lint UIXML.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
s.name      = 'UIXML'
s.version   = '1.2.0'
s.license  = 'unspecified'
s.platform  = :ios
s.summary   = 'Generate Form based upon UITableView from .plist file(s)'
s.description = 'Generate Form based upon UITableView from .plist file(s)'
s.homepage  = 'https://github.com/bsorrentino/UIXML'
s.author    = { 'bsorrentino' =>  ' bartolomeo.sorrentino@gmail.com' }
s.source    = { :git => 'https://github.com/bsorrentino/UIXML.git', :tag => '1.2.0' }
#s.source    = { :git => 'https://github.com/bsorrentino/UIXML.git', :commit => '3ef22aec4c6f2ef8bc9f4dd8380854f98cad34b9' }
s.source_files = '*.{h,m}'
s.resources = "*.png", "*.xib", "en.lproj/*.xib"
s.frameworks = 'Foundation'
s.exclude_files = "UIXML.xcodeproj", "Samples", "README.md"
s.requires_arc = true

end
