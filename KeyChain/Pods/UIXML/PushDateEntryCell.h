//
//  PushDateEntryCell.h
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXML.h"
#import "PushControllerDataEntryCell.h"

@class PushDateEntryCell;

@interface PushDateViewController : UIViewController {
	

@private
	UIDatePicker *__UIXML_WEAK datePicker;
	UIBarButtonItem *__UIXML_WEAK btnSave;
	UITextField  *__UIXML_WEAK txtValue;
	
	PushDateEntryCell *__UIXML_WEAK _cell;
}
@property (UIXML_WEAK, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (UIXML_WEAK,nonatomic) IBOutlet UIBarButtonItem *btnSave;
@property (UIXML_WEAK,nonatomic) IBOutlet UITextField  * txtValue;


- (IBAction) selectValue: (id)sender;
- (IBAction) saveValue: (id)sender;

- (void) initWithCell:(PushDateEntryCell*)cell;

@end 


@interface PushDateEntryCell  : PushControllerDataEntryCell {
	
@private
	PushDateViewController *__UIXML_WEAK viewController;
	UITextField  *__UIXML_WEAK txtValue;
	
	NSDateFormatter * dateFormatter_;
}

- (NSString *) stringFromDate:(NSDate *)value;

@property (UIXML_STRONG,nonatomic, readonly)NSDateFormatter *dateFormatter;
//@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (UIXML_WEAK,nonatomic) IBOutlet UITextField  * txtValue;
@property (UIXML_WEAK,nonatomic) IBOutlet PushDateViewController *viewController;


@end


