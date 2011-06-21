//
//  WebViewController.h
//  ZZGridView
//
//

#import <UIKit/UIKit.h>

#import "PushControllerDataEntryCell.h"
#import "WaitMaskController.h"

@interface WebViewController : UIViewController<UIWebViewDelegate,UITextFieldDelegate> {
	IBOutlet UIWebView *webView;
	//NSString *url;
    
    UIView *addressView;
    id<BaseDataEntryCellDelegate> delegate;
    
@private    
    WaitMaskController *waitController_;
    UITextField *txtURL_;
    UIBarButtonItem *editButton_;
    UIBarButtonItem *saveButton_;
    BOOL isPossibleSave;

}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *addressView;
@property (nonatomic, retain) IBOutlet UITextField *txtURL;

@property (nonatomic, retain)  NSString *url;
@property (nonatomic, readonly) WaitMaskController *waitController;

@property (nonatomic, assign) id<BaseDataEntryCellDelegate> delegate;

@end


@interface PushWebViewEntryCell : PushControllerDataEntryCell {
	
@private
	WebViewController *viewController;
    UITextField *txtValue;
    
}

@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UITextField *textValue;
@property (nonatomic, retain) IBOutlet WebViewController *viewController;

@end
