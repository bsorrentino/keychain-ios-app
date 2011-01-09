//
//  PushDateEntryCell.h
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PushControllerDataEntryCell.h"

@class PushDateEntryCell;

@interface PushDateViewController : UIViewController {
	

@private
	UIDatePicker *datePicker;
	
	PushDateEntryCell *_cell;
}
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;


- (IBAction) selectValue: (id)sender;

- (void) initWithCell:(PushDateEntryCell*)cell;

@end 


@interface PushDateEntryCell  : PushControllerDataEntryCell {
	
@private
	PushDateViewController *viewController;
	UITextField  * txtValue;
	
	NSDateFormatter *_dateFormatter;
}

@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UITextField  * txtValue;
@property (nonatomic, retain) IBOutlet PushDateViewController *viewController;


@end


