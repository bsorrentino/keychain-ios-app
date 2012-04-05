//
//  WebViewController.h
//  ZZGridView
//
//

#import <UIKit/UIKit.h>

#import "PushControllerDataEntryCell.h"
#import "WaitMaskController.h"

@interface UIWebViewEx : UIWebView {
        
}

@end

@interface WebViewController : UIViewController<UIWebViewDelegate,UITextFieldDelegate> {
	IBOutlet UIWebViewEx *webView;
    
    UIView *addressView;
    id<BaseDataEntryCellDelegate> __unsafe_unretained delegate;
    
@private    
    WaitMaskController *waitController_;
    UITextField *txtURL_;
    UIBarButtonItem *editButton_;
    
    BOOL forceReload_;
    

}

@property (nonatomic) NSString *url;

@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) IBOutlet UIView *addressView;
@property (nonatomic) IBOutlet UITextField *txtURL;


@property (unsafe_unretained, nonatomic, readonly) WaitMaskController *waitController;

@property (nonatomic, unsafe_unretained) id<BaseDataEntryCellDelegate> delegate;


@end


@interface PushWebViewEntryCell : PushControllerDataEntryCell {
	
@private
	WebViewController *viewController;
    UITextField *textValue;
    UILabel *textLabel_;
    
}

//@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic) IBOutlet UITextField *textValue;
@property (nonatomic) IBOutlet WebViewController *viewController;
@property (nonatomic) IBOutlet UILabel *textLabel;

@end
