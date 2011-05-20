//
//  WebViewController.h
//  ZZGridView
//
//

#import <UIKit/UIKit.h>

#import "PushControllerDataEntryCell.h"

@interface WebViewController : UIViewController<UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	NSString *url;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain)  NSString *url;

@end


@interface PushWebViewEntryCell : PushControllerDataEntryCell<UITextFieldDelegate> {
	
@private
	UITextField *textField;
	WebViewController *viewController;
    
}

@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet WebViewController *viewController;
@property (nonatomic, retain) IBOutlet UITextField *textField;

@end
