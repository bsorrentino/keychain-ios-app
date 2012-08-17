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

- (id) init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData {
	
    if ((self = [super init:controller datakey:key label:label cellData:cellData])) {
        // Initialization code
		_owner = controller;
    }
	
	return self;
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
