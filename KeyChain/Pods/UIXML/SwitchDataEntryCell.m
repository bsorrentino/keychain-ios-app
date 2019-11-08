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


-(void)valueChanged:(id)sender {

	NSLog(@"sender [%@]", sender );
	[super postEndEditingNotification];
}

-(void)prepareToAppear:(UIXMLFormViewController*)controller datakey:(NSString *)key cellData:(NSDictionary*)cellData {
	
    [super prepareToAppear:controller datakey:key cellData:cellData];
    // Initialization code
    [switchField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

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



@end
