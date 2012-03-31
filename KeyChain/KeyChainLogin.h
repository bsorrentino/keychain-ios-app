//
//  KeyChainLogin.h
//  KeyChain
//
//  Created by softphone on 16/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WEPopoverController;

typedef enum {
    NONE = 0, 
    CHECKPASSWORD, 
    GETNEWPASSWORD, 
    CHECKNEWPASSWORD 
} ChangePasswordStep;

@interface KeyChainLogin : UIViewController<UITextFieldDelegate> {

@private	
    
	UITextField *txtPassword;
    ChangePasswordStep changePasswordStep_;
    UIViewController *parent_;
    
    UIBarButtonItem *btnVersion_;
    UIBarButtonItem *btnInfo_;
    
    UIToolbar *toolBar;
    
    // POPOVER SECTION
	WEPopoverController *popoverController;
    
}

@property (nonatomic,assign) UIViewController *parent;
@property (nonatomic,retain) IBOutlet UITextField *txtPassword;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnVersion;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnInfo;
@property (nonatomic, retain) WEPopoverController *popoverController;
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;

@property (nonatomic,retain) NSString *password;
@property (nonatomic,retain) NSString *version;


-(id)initForChangePassword;
- (IBAction)login:(id)sender;
- (IBAction)info:(id)sender;

+ (void)doModal:(UIViewController *)root ;

@end
