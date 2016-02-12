//
//  KeyChainLogin.m
//  KeyChain
//
//  Created by softphone on 16/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyChainLogin.h"
#import "InfoViewController.h"
#import "WEPopoverController.h"

@import LocalAuthentication;

#define TAG_FOR_LOGIN_BUTTON 5

@interface KeyChainLogin()


- (BOOL)loginToSystem;
- (BOOL)changePassword;
- (void)doModal:(UIViewController *)root onLoggedIn:(dispatch_block_t)block;
- (void)getNewPassword;
- (void)loginUsingTouchID;

@end

@implementation KeyChainLogin

@synthesize txtPassword;
@synthesize parent=parent_;

@synthesize btnVersion=btnVersion_;
@synthesize btnInfo=btnInfo_;

@synthesize popoverController;
@synthesize toolBar;

#pragma mark - private implementation


- (void)loginUsingTouchID {
    __BLOCKSELF ;
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ) {
        NSString *p = [AccountCredential sharedCredential].password;
        if ( p!=nil ) {
            
            LAContext *localAuthenticationContext = [[LAContext alloc] init];
            
            __autoreleasing NSError *authenticationError;
            
            NSString *localizedReasonString = NSLocalizedString(@"Authenticate and log into your account.", @"String to prompt the user why we're using Touch ID.");
            
            if([localAuthenticationContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authenticationError]) {
                [localAuthenticationContext
                 evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                 localizedReason:localizedReasonString
                 reply:^(BOOL success, NSError *error) {
                     if (success) {
                         NSLog(@"ACCESS GRANTED!");
                         if( _onLoggedIn ) _onLoggedIn();
                         
                         [__self dismissViewControllerAnimated:YES completion:^{
                             [__self.parent.view setHidden:NO];
                         }];

                     } else {
                         //Touch ID failed, check the code property on the error object
                         NSLog(@"ACCESS DENIED!");
                     }
                 }];
            } else {
                //Error using Touch ID -- most likely not a TouchID supported device
                NSLog(@"TOUCHID DEVICE IS NOT PRESENT!");
            }
        }
    }
    
}

- (BOOL)loginToSystem {
    __BLOCKSELF ;
    
	NSString *p = [AccountCredential sharedCredential].password;
	if ( p==nil ) {
		[AccountCredential sharedCredential].password = txtPassword.text;
		self.txtPassword.text = @"";
		self.txtPassword.placeholder = NSLocalizedString(@"login.confirmPassword", @"");
		return NO;
	}
	
	if ([p compare: txtPassword.text] != 0 ) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password doesn't match!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
        
        self.txtPassword.text = @"";
		return NO;
		
	}
    
    if( _onLoggedIn ) _onLoggedIn();
    
    [self.parent dismissViewControllerAnimated:YES completion:^{
        [__self.parent.view setHidden:NO];
    }];
    
	return YES;
}


- (void) getNewPassword {

    self.txtPassword.text = @"";
    self.txtPassword.placeholder = NSLocalizedString(@"login.newPassword", @"");
    changePasswordStep_ = GETNEWPASSWORD;
    
}

- (BOOL)changePassword {

    static NSString *tmpPassword_;
    
    BOOL result = NO;
    
    //
    // STEP 1 - CHECK PASSWORD 
    //
    
    //
    // STEP 2 - GET NEW PASSWORD 
    //
    
    //
    // STEP 3 - RETYPE NEW PASSWORD 
    //
    
    //
    // STEP 4 - CHECK NEW PASSWORD 
    //
    
    switch (changePasswordStep_) {
        case CHECKPASSWORD:
        {
            NSString *p = [AccountCredential sharedCredential].password;

            if ([p compare: txtPassword.text] != 0 ) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password doesn't match!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
                
                
            }
            else {
                
                [self getNewPassword];
            }
            
        }
            break;
        case GETNEWPASSWORD:
        {
            tmpPassword_ = [self.txtPassword.text copy];
            
            self.txtPassword.text = @"";
            self.txtPassword.placeholder = NSLocalizedString(@"login.confirmNewPassword", @"");
            changePasswordStep_ = CHECKNEWPASSWORD;
        }
            break;
        case CHECKNEWPASSWORD:
        {
            
            if ([tmpPassword_ compare: self.txtPassword.text] != 0 ) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password doesn't match!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];

                [self getNewPassword];
                
            }
            else {
                
                [AccountCredential sharedCredential].password = tmpPassword_;
                result = YES;
                [self.navigationController popViewControllerAnimated:YES]; 
            }

        }
            break;
        default:
            result = YES;
            break;
    }
    
	return result;
    
}

- (void)doModal:(UIViewController *)root onLoggedIn:(dispatch_block_t)block
{

    _onLoggedIn = block;
    
    self.title = @"";
    
    changePasswordStep_ = NONE;
    
    
    __block UIViewController *_root = root;
    
	//self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
    //[root presentModalViewController:self animated:YES];
    [root presentViewController:self animated:YES completion:^{
        [_root.view setHidden:YES];
    }];
    self.parent = root;
}


#pragma mark - KeyChainLogin 


+ (void)doModal:(UIViewController *)root onLoggedIn:(dispatch_block_t)block {
    
    __block KeyChainLogin *login = [[KeyChainLogin alloc] initWithNibName:@"KeyChainLogin" bundle:nil] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [login	doModal:root onLoggedIn:block];
    });
    
}

- (id)initForChangePassword  {
    
    if( self = [super initWithNibName:@"KeyChainLogin" bundle:nil]  ) {
        changePasswordStep_ = CHECKPASSWORD;
        self.title = @"Change Password";
        
        UIView *button = [self.view viewWithTag:TAG_FOR_LOGIN_BUTTON];
        if( button!=nil ) {
            [button setHidden:YES];
        }
        return self;
    }
    return nil;
}


- (IBAction)info:(id)sender  {
    

    
	if (!self.popoverController) {
		
        InfoViewController *contentViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
		
        contentViewController.preferredContentSize = CGSizeMake(270, 300);
        
        self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
		
        //self.popoverController.delegate = self;

        /*
		self.popoverController.passthroughViews = 
            [NSArray arrayWithObject:self.navigationController.navigationBar];
		
         [self.popoverController presentPopoverFromBarButtonItem:sender 
									   permittedArrowDirections:UIPopoverArrowDirectionDown 
													   animated:YES];
         */
      
    } 

     [self.popoverController presentPopoverFromBarButtonItem:sender 
                                                     toolBar:self.toolBar
                                    permittedArrowDirections:UIPopoverArrowDirectionDown 
                                                    animated:YES];
}

- (IBAction)login:(id)sender {

	[self loginToSystem];
}

#pragma mark -
#pragma mark inherit from UITextFieldDelegate
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (changePasswordStep_ != NONE ) {
        return [self changePassword];
    }
    return [self loginToSystem];
}

#pragma mark inherit from UIViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    NSString *_bundleVersion = [AccountCredential sharedCredential].bundleVersion;

	txtPassword.delegate = self;
    
    NSLog(@"bundle version [%@]", _bundleVersion );
    
    NSString *versionTitle = [NSString stringWithFormat:self.btnVersion.title, _bundleVersion];
    
    self.btnVersion.title = versionTitle;
    

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __BLOCKSELF ;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ( [[AccountCredential sharedCredential] checkAndUpdateCurrentVersion] ) {
            
            [__self info:__self.btnInfo];
        }
    });
    
   
    
}

//
-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    __BLOCKSELF ;

    dispatch_async(dispatch_get_main_queue(), ^{
        [__self loginUsingTouchID];
    });
    

    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
