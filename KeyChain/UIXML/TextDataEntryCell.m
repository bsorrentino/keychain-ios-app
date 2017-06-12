//
//  TextDataEntryCell.m
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import "TextDataEntryCell.h"

@interface TextDataEntryCell()

@end

NSString *const TextDataEntryCellNotification = @"TextDataEntryCell.scrollUpToKeyboard";

@implementation TextDataEntryCell

@synthesize textField;

#pragma mark - BaseDataEntryCellWithResponder implementation


-(UIResponder *)getResponder
{
    return self.textField;
}


#pragma mark - Inherit from UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// Rect area del textbox
	/*
	CGRect rect = CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width  + LABEL_CONTROL_PADDING, 
							 12.0, 
							 self.contentView.frame.size.width-(self.textLabel.frame.size.width + LABEL_CONTROL_PADDING + self.textLabel.frame.origin.x)-RIGHT_PADDING, 
							 25.0);
	*/
	
	CGRect rect = [super getRectRelativeToLabel:textField.frame padding:LABEL_CONTROL_PADDING rpadding:RIGHT_PADDING];
	[textField setFrame:rect];
}

#pragma mark Inherit from BaseDataEntryCell

- (void) prepareToAppear:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData{
	
    [super prepareToAppear:controller datakey:key label:label cellData:cellData];
    // Initialization code
	
    NSString *placeholder = [cellData objectForKey:@"placeholder"];
    
    if( ![self isStringEmpty:placeholder] ) {
        
        [textField setPlaceholder:placeholder];
    }

    NSNumber * isSecure = [cellData objectForKey:@"secure"];
    if( isSecure != nil ) {
        textField.secureTextEntry = [isSecure boolValue];
        
    }
    
    NSNumber * autocorrectionType = (NSNumber *)[cellData objectForKey:@"autocorrectionType"];
    
    if( autocorrectionType!=nil ) {
        
        textField.autocorrectionType = ( [autocorrectionType boolValue] ) ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo;
            
    }

    NSString *autocapitalizationType = (NSString*)[cellData objectForKey:@"autocapitalizationType"];
    
    if( ![self isStringEmpty:autocapitalizationType] ) {
        /*
        UITextAutocapitalizationTypeNone,
        UITextAutocapitalizationTypeWords,
        UITextAutocapitalizationTypeSentences,
        UITextAutocapitalizationTypeAllCharacters,
        */
        if( [autocapitalizationType compare:@"None" options:NSCaseInsensitiveSearch]==NSOrderedSame ) {

            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
        } else if ( [autocapitalizationType compare:@"Words" options:NSCaseInsensitiveSearch]==NSOrderedSame ) {

            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;

        } else if ( [autocapitalizationType compare:@"Sentences" options:NSCaseInsensitiveSearch]==NSOrderedSame ) {

            textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            
        } else if ( [autocapitalizationType compare:@"AllCharacters" options:NSCaseInsensitiveSearch]==NSOrderedSame ) {
        
            textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            
        }
    }
		
}

-(void) setControlValue:(id)value
{
	if (value==nil) {
		self.textField.text = @"";
	}
	else {
		self.textField.text = value;
	}
}

-(id) getControlValue
{
	return self.textField.text;
}

-(void)setEnabled:(BOOL)value {
	self.textField.enabled = value;
}

-(BOOL)enabled {
	return self.textField.enabled ;
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)txtField {

	return YES;
	
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)txtField {
	if( [txtField isFirstResponder] ) {
		[txtField resignFirstResponder];
	}
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)txtField {
	if( [txtField isFirstResponder] ) {
		[txtField resignFirstResponder];
	}
	return YES;
	
}

- (void)textFieldDidEndEditing:(UITextField *)txtField
{
	[self postEndEditingNotification];
}



@end
