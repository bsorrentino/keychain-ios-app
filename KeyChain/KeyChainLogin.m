//
//  KeyChainLogin.m
//  KeyChain
//
//  Created by softphone on 16/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyChainLogin.h"


@implementation KeyChainLogin

@synthesize txtPassword;

#pragma mark KeyChainLogin 

- (BOOL)login_ {
	
	NSString *p = self.password;
	if ( p==nil ) {
		self.password = txtPassword.text;
		self.txtPassword.text = @"";
		self.txtPassword.placeholder = @"confirm password";
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

- (IBAction)login:(id)sender {

	[self login_];
}

- (void)doModal:(UIViewController *)root {
	[root.view setHidden:YES];

	//self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[root presentModalViewController:self animated:YES];
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
	return [self login_];
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
