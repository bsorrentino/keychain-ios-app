//
//  KeyChainLogin.h
//  KeyChain
//
//  Created by softphone on 16/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KeyChainLogin : UIViewController {

@private	
	UITextField *txtPassword;
}

@property (nonatomic,retain) IBOutlet UITextField *txtPassword;
@property (nonatomic,retain) NSString *password;

- (IBAction)login:(id)sender;
- (void)doModal:(UIViewController *)root ;
@end
