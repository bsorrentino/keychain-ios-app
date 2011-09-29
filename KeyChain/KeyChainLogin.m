//
//  KeyChainLogin.m
//  KeyChain
//
//  Created by softphone on 16/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyChainLogin.h"


@interface KeyChainLogin(Private)


- (BOOL)loginToSystem;
- (BOOL)changePassword;
- (void)doModal:(UIViewController *)root;
- (void)getNewPassword;


@end

@implementation KeyChainLogin

@synthesize txtPassword;

#pragma mark - private implementation

- (BOOL)loginToSystem {
	
	NSString *p = self.password;
	if ( p==nil ) {
		self.password = txtPassword.text;
		self.txtPassword.text = @"";
		self.txtPassword.placeholder = NSLocalizedString(@"login.confirmPassword", @"");
		return NO;
	}
	
	if ([p compare: txtPassword.text] != 0 ) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password doesn't match!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
		
	}
	
	[self.parentViewController.view setHidden:NO];
	[[self.parentViewController modalViewController] dismissModalViewControllerAnimated:YES];
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
            NSString *p = self.password;

            if ([p compare: txtPassword.text] != 0 ) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password doesn't match!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                
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
                [alert release];

                [self getNewPassword];
                
            }
            else {
                
                self.password = tmpPassword_;
                result = YES;
                [self.navigationController popViewControllerAnimated:YES]; 
            }

            [tmpPassword_ release];
        }
            break;
        default:
            result = YES;
            break;
    }
    
	return result;
    
}

- (void)doModal:(UIViewController *)root {
    
    self.title = @"";
    
    changePasswordStep_ = NONE;
    
	[root.view setHidden:YES];
    
	//self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[root presentModalViewController:self animated:YES];
}


#pragma mark - KeyChainLogin 


+ (void)doModal:(UIViewController *)root {
    
    KeyChainLogin *login = [[KeyChainLogin alloc] initWithNibName:@"KeyChainLogin" bundle:nil] ;
    [login	doModal:root];
    
    [login release];
}

- (id)initForChangePassword  {
    
    if( [super initWithNibName:@"KeyChainLogin" bundle:nil] !=nil ) {
        changePasswordStep_ = CHECKPASSWORD;
        self.title = @"Change Password";
        return self;
    }
    return nil;
}

- (IBAction)login:(id)sender {

	[self loginToSystem];
}


-(NSString*) password {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *result = [prefs objectForKey:@"pwd"];
	return result;
}

-(void) setPassword:(NSString *)value {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:value forKey:@"pwd"];
	[prefs synchronize];
}

#pragma mark inherit from UITextFieldDelegate

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
	
	txtPassword.delegate = self;
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


- (void)dealloc {
    [super dealloc];
}


@end
