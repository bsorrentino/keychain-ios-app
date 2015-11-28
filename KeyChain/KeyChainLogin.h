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
    UIViewController *__unsafe_unretained parent_;
    
    UIBarButtonItem *btnVersion_;
    UIBarButtonItem *btnInfo_;
    
    UIToolbar *toolBar;
    
    // POPOVER SECTION
	WEPopoverController *popoverController;
    
    dispatch_block_t _onLoggedIn;
}

@property (nonatomic,unsafe_unretained) UIViewController *parent;
@property (nonatomic) IBOutlet UITextField *txtPassword;
@property (nonatomic) IBOutlet UIBarButtonItem *btnVersion;
@property (nonatomic) IBOutlet UIBarButtonItem *btnInfo;
@property (nonatomic, strong) WEPopoverController *popoverController;
@property (nonatomic) IBOutlet UIToolbar *toolBar;

-(id)initForChangePassword;
- (IBAction)login:(id)sender;
- (IBAction)info:(id)sender;

+ (void)doModal:(UIViewController *)root onLoggedIn:(dispatch_block_t)block;

@end
