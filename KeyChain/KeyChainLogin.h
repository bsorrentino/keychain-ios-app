//
//  KeyChainLogin.h
//  KeyChain
//
//  Created by softphone on 16/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NONE = 0, CHECKPASSWORD, GETNEWPASSWORD, CHECKNEWPASSWORD 
} ChangePasswordStep;

@interface KeyChainLogin : UIViewController<UITextFieldDelegate> {

@private	
    
	UITextField *txtPassword;
    ChangePasswordStep changePasswordStep_;
}

@property (nonatomic,retain) IBOutlet UITextField *txtPassword;
@property (nonatomic,retain) NSString *password;

-(id)initForChangePassword;
- (IBAction)login:(id)sender;

+ (void)doModal:(UIViewController *)root ;

@end
