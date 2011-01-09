//
//  PushControllerDataEntryCell.h
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"BaseDataEntryCell.h"

@class UIXMLFormViewController;

@interface PushControllerDataEntryCell : BaseDataEntryCell {

@protected
	UIXMLFormViewController *_owner;
}

@property (readonly) UIXMLFormViewController *owner;

-(UIViewController *)viewController:(NSDictionary*)cellData;
	
@end
