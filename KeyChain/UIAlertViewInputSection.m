//
//  UIAlertViewInputSection.m
//  KeyChain
//
//  Created by softphone on 14/02/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "UIAlertViewInputSection.h"
#import "KeyEntity.h"

@interface UIAlertViewInputSection (Private) {
}

- (BOOL)isSectionAware:(NSString *)key;
- (void)processInputText;

@end

@implementation UIAlertViewInputSection

@synthesize groupName, groupPrefix;
//@synthesize delegate;
@synthesize clickedButtonAtIndexBlock=clickedButtonAtIndexBlock_;

- (id)init  {

    return [self initWithTitle:NSLocalizedString(@"AlertViewInputSection.alertTitle", @"add new Item") ];
}

- (id)initWithTitle:(NSString *)title  {
    
        
    if (self = [super init]) {
    
        
        alert_ = [[UIAlertView alloc] 
                              initWithTitle:title
                              message:NSLocalizedString(@"AlertViewInputSection.alertMessage", @"add item message") 
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"OK", nil];
        
        // Name field
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
        tf.tag = 100;
        tf.keyboardType = UIKeyboardTypeEmailAddress;
        tf.placeholder = NSLocalizedString(@"AlertViewInputSection.alertPlaceholder", @"add item placeholder");
        [tf setBackgroundColor:[UIColor whiteColor]]; 
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.keyboardType = UIKeyboardTypeAlphabet;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters; //UITextAutocapitalizationTypeWords;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf becomeFirstResponder];
        [alert_ addSubview:tf];	

    }
    
    return self;
}


- (BOOL)isSectionAware:(NSString *)key {

    static  NSString * _REGEXP = @"(\\w+)[-@/]";
    
    
    NSPredicate *predicate = 
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@",  _REGEXP];
    
    BOOL result = [predicate evaluateWithObject:key];
    
    
    return result;
}


- (void)processInputText {
 
        groupName = nil;
        groupPrefix = nil;

        if (alert_ == nil ) {
            return;
        }
        
        UITextField *tf = (UITextField*)[alert_ viewWithTag:100];
        
        NSString *trimmed = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if( [trimmed length] == 0 ) {
            return ;
        }

        if( [self isSectionAware:trimmed] ) {
            
            groupPrefix = trimmed;
            groupName = [KeyEntity sectionNameFromPrefix:groupPrefix trim:NO];
        }
        else {
            groupPrefix = [trimmed stringByAppendingString:@"-"];
            groupName = trimmed;
        }
}

- (void)show {
    [alert_ show];
}



#pragma mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self processInputText];
    
    if (clickedButtonAtIndexBlock_!=nil) {
        clickedButtonAtIndexBlock_( self, buttonIndex);
    }
        
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
//- (void)alertViewCancel:(UIAlertView *)alertView;

//- (void)willPresentAlertView:(UIAlertView *)alertView;  // before animation and showing view
//- (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation

//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

// Called after edits in any of the default fields added by the style
//- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView ;


@end
