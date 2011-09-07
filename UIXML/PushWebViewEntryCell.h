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
	//NSString *url;
    
    UIView *addressView;
    id<BaseDataEntryCellDelegate> delegate;
    
@private    
    WaitMaskController *waitController_;
    UITextField *txtURL_;
    UIBarButtonItem *editButton_;
    UIBarButtonItem *saveButton_;
    
    BOOL isPossibleSave;
    BOOL forceReload_;
    

}

@property (nonatomic, retain) NSString *url;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *addressView;
@property (nonatomic, retain) IBOutlet UITextField *txtURL;


@property (nonatomic, readonly) WaitMaskController *waitController;

@property (nonatomic, assign) id<BaseDataEntryCellDelegate> delegate;


@end


@interface PushWebViewEntryCell : PushControllerDataEntryCell {
	
@private
	WebViewController *viewController;
    UITextField *textValue;
    UILabel *textLabel_;
    
}

//@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UITextField *textValue;
@property (nonatomic, retain) IBOutlet WebViewController *viewController;
@property (nonatomic,retain) IBOutlet UILabel *textLabel;

@end
