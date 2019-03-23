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
@synthesize textLabel;

#pragma mark - BaseDataEntryCellWithResponder implementation


-(UIResponder *)getResponder
{
    return self.textField;
}


#pragma mark - Inherit from UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
}

#pragma mark Inherit from BaseDataEntryCell

-(void)prepareLabelToAppear:(NSDictionary*_Nonnull)cellData
{
    [self processLabelConfig:cellData dataView:self.textField];
}

- (void) prepareToAppear:(UIXMLFormViewController*)controller datakey:(NSString*)key cellData:(NSDictionary*)cellData{
	
    [super prepareToAppear:controller datakey:key cellData:cellData];
    
    [cellData getStringForKey:@"placeholder" next:^(NSString * _Nonnull value) {
        [self->textField setPlaceholder:value];
    } complete:^{
        [self->textField setPlaceholder:@""];
    }];
    [cellData getNumberForKey:@"secure" next:^(NSNumber * _Nonnull value) {
        self->textField.secureTextEntry = [value boolValue];
    }];
    [cellData getNumberForKey:@"autocorrectionType" next:^(NSNumber * _Nonnull value) {
        self->textField.autocorrectionType =
            ( [value boolValue] ) ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo;
    }];
    [cellData getStringForKey:@"autocapitalizationType" next:^(NSString * _Nonnull value) {
        /*
         UITextAutocapitalizationTypeNone,
         UITextAutocapitalizationTypeWords,
         UITextAutocapitalizationTypeSentences,
         UITextAutocapitalizationTypeAllCharacters,
         */
        if( [value compare:@"None" options:NSCaseInsensitiveSearch]==NSOrderedSame ) {
            self->textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        } else if ( [value compare:@"Words" options:NSCaseInsensitiveSearch]==NSOrderedSame ) {
            self->textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        } else if ( [value compare:@"Sentences" options:NSCaseInsensitiveSearch]==NSOrderedSame ) {
            self->textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        } else if ( [value compare:@"AllCharacters" options:NSCaseInsensitiveSearch]==NSOrderedSame ) {
            self->textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        }
    }];
		
}

-(void) setControlValue:(id)value
{
    self.textField.text = (value==nil) ? @"" : value;
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
