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
	UIBarButtonItem *btnSave;
	UITextField  * txtValue;
	
	PushDateEntryCell *_cell;
}
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnSave;
@property (nonatomic, retain) IBOutlet UITextField  * txtValue;


- (IBAction) selectValue: (id)sender;
- (IBAction) saveValue: (id)sender;

- (void) initWithCell:(PushDateEntryCell*)cell;

@end 


@interface PushDateEntryCell  : PushControllerDataEntryCell {
	
@private
	PushDateViewController *viewController;
	UITextField  * txtValue;
	
	NSDateFormatter *dateFormatter_;
}

- (NSString *) stringFromDate:(NSDate *)value;

@property (nonatomic, readonly)NSDateFormatter *dateFormatter;
//@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UITextField  * txtValue;
@property (nonatomic, retain) IBOutlet PushDateViewController *viewController;


@end


