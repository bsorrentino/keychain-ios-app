//
//  PushControllerDataEntryCell.m
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PushControllerDataEntryCell.h"
#import "UIXMLFormViewController.h"

@implementation PushControllerDataEntryCell

@synthesize owner;

- (void) prepareToAppear:(UIXMLFormViewController*)controller datakey:(NSString*)key  cellData:(NSDictionary*)cellData {
	
    [super prepareToAppear:controller datakey:key cellData:cellData];

    _owner = controller;
}

-(UIXMLFormViewController *)owner {
	return _owner;
}

-(UIViewController *)viewController:(NSDictionary*)cellData {

    /*
     
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                    reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                    userInfo:nil];	
    */ 
    return nil;
}


#pragma mark -
#pragma mark inherit from UITableViewCell
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}



@end
