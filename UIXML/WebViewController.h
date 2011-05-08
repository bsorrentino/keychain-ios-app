//
//  WebViewController.h
//  ZZGridView
//
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController<UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	NSString *url;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain)  NSString *url;

@end
