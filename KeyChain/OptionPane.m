//
//  OptionPane.m
//  KeyChain
//
//  Created by softphone on 20/10/11.
//  Copyright (c) 2011 SOFTPHONE. All rights reserved.
//

#import "OptionPane.h"

@implementation OptionPane

/*
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView;

- (void)willPresentAlertView:(UIAlertView *)alertView;  // before animation and showing view
- (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView;
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if( buttonIndex == 0 ) {
        if( okBlock_ !=nil)    okBlock_();
        return;
    }
    if( buttonIndex == 1 ) {
        if( cancelBlock_!=nil ) cancelBlock_();
        return;
    }
}

- (id)initWithOKBlock:(void (^)())OKBlock CancelBlock:(void (^)())CancelBlock {
    okBlock_ = OKBlock;
    cancelBlock_ = CancelBlock;
    return self;
}

+ (void) showOKCancelAlert:(NSString *)title 
                   message:(NSString *)message
                   OKTitle:(NSString *)OKtitle OKBlock:(void (^)())OKBlock 
               CancelTitle:(NSString*)CancelTitle CancelBlock:(void (^)())CancelBlock {
    
    OptionPane *pane = [[OptionPane alloc] initWithOKBlock:OKBlock CancelBlock:CancelBlock];
    
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title 
                                                     message:message
                                                    delegate:pane 
                                           cancelButtonTitle:OKtitle
                                           otherButtonTitles:CancelTitle, nil] autorelease];
    [alert show];
    
    
}


@end
