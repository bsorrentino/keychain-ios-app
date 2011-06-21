//
//  UIWaitCompletionView.m
//  KeyChain
//
//  Created by softphone on 19/06/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import "WaitMaskController.h"


@implementation WaitMaskController


- (void)mask:(NSString*)title {
    
	if (waitView_==nil) {
		waitView_ = 
            [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
		[waitView_ show];
        
		UIActivityIndicatorView *indicator = 
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		
		// Adjust the indicator so it is up a few pixels from the bottom of the alert
		indicator.center = CGPointMake(waitView_.bounds.size.width / 2, waitView_.bounds.size.height - 50);
		[indicator startAnimating];
		[waitView_ addSubview:indicator];
		[indicator release];
	}
	else {
		waitView_.title = title;
		if( !waitView_.visible )
			[waitView_ show];
		
	}
	
	
}

- (void)unmask {
	
	if( waitView_!=nil ) {
		[waitView_ dismissWithClickedButtonIndex:0 animated:YES];
        
	}
}


#pragma mark UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView {
    
}

// before animation and showing view
- (void)willPresentAlertView:(UIAlertView *)alertView {  
}

// after animation
- (void)didPresentAlertView:(UIAlertView *)alertView {  

}

// before animation and hiding view
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex { 
}

// after animation
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex { 

}

@end
