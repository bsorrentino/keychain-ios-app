#
#  Be sure to run `pod spec lint ZKRevealingTableViewCell.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name         = 'ZKRevealingTableViewCell'
s.version      = '0.1.2'
s.license      = 'MIT'
s.summary      = 'A Sparrow-style Implementation of Swipe-To-Reveal. (bsorrentino fork)'
s.homepage     = 'https://github.com/alexzielenski/ZKRevealingTableViewCell'
s.author       = { 'Alex Zielenski' => 'support@alexzielenski.com', "bsorrentino" =>'bartolomeo.sorrentino@gmail.com' }
s.source       = { :git => 'https://github.com/bsorrentino/ZKRevealingTableViewCell.git', :tag => '0.1.2' }
s.description  = 'A different kind of swipe-to-reveal that pans with your finger and works left and right to reveal a background view.'
s.platform     = :ios
s.source_files = 'vendor'
s.exclude_files  = "ZKRevealingTableViewCell", "ZKRevealingTableViewCell.xcodeproj", "Preview.png"
s.framework    = 'QuartzCore'
s.requires_arc = true

end
