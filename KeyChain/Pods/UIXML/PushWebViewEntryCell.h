//
//  WebViewController.h
//  ZZGridView
//
//
//
//
//  Due ATS (App Transport Security), a new feature in iOS 9 that checks the authenticity of a URL before
//  connecting to it,  We have disabled it entirely.
//  This can be done by adding the following code to the app's info.plist file:
//
//  <key>NSAppTransportSecurity</key>
//  <dict>
//      <key>NSAllowsArbitraryLoads</key>
//      <true/>
//  </dict>
//
// @see https://stackoverflow.com/a/32532310/521197
//

#import <UIKit/UIKit.h>
#import "UIXML.h"
#import "PushControllerDataEntryCell.h"
#import "WaitMaskController.h"

@interface UIWebViewEx : UIWebView {
        
}

@end

@interface WebViewController : UIViewController<UIWebViewDelegate,UITextFieldDelegate> {
	IBOutlet UIWebViewEx *__UIXML_WEAK webView;
    
    UIView *__UIXML_WEAK addressView;
    id<BaseDataEntryCellDelegate> __UIXML_WEAK delegate;
    
@private    
    WaitMaskController * waitController_;
    UITextField *__UIXML_WEAK txtURL_;
    UIBarButtonItem *editButton_;
    
    BOOL forceReload_;
    

}

@property (UIXML_STRONG,nonatomic) NSString *url;

@property (UIXML_WEAK,nonatomic) IBOutlet UIWebView *webView;
@property (UIXML_WEAK,nonatomic) IBOutlet UIView *addressView;
@property (UIXML_WEAK,nonatomic) IBOutlet UITextField *txtURL;


@property (UIXML_STRONG, nonatomic, readonly) WaitMaskController *waitController;

@property (nonatomic, UIXML_WEAK) id<BaseDataEntryCellDelegate> delegate;


@end


@interface PushWebViewEntryCell : PushControllerDataEntryCell {
	
@private
	WebViewController *__UIXML_STRONG viewController;
    UITextField *__UIXML_WEAK textValue;
    UILabel *__UIXML_WEAK textLabel_;
    
}

@property (UIXML_STRONG,nonatomic) IBOutlet WebViewController *viewController;
@property (UIXML_WEAK,nonatomic) IBOutlet UITextField *textValue;
@property (UIXML_WEAK,nonatomic) IBOutlet UILabel *textLabel;

@end
