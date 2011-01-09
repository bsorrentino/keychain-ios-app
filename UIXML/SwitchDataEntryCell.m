//
//  SwitchDataEntryCell.m
//  TableViewDataEntry
//
//  Created by softphone on 20/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SwitchDataEntryCell.h"


@implementation SwitchDataEntryCell

@synthesize switchField;
@synthesize textLabel;


-(void)valueChanged:(id)sender {

	NSLog(@"sender [%@]", sender );
	[super postEndEditingNotification];
}

-(id)init:(UIXMLFormViewController*)controller datakey:(NSString *)key label:(NSString*)label cellData:(NSDictionary*)cellData {
	
    if ((self = [super init:controller datakey:key label:label cellData:cellData])) {
        // Initialization code
		
		[switchField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

    }
	
    return self;
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
// Imposta il valore del controllo gestito (TextField, ...)
-(void) setControlValue:(id)value {
	
	switchField.on = [(NSNumber *)value boolValue];
}

// Legge il valore dal controllo
-(id) getControlValue {

	return [NSNumber numberWithBool:switchField.on];
}

- (void)dealloc {
    [super dealloc];
}


@end
