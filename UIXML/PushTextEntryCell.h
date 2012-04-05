//
//  PushTextEntryCell.h
//  UIXML
//
//  Created by softphone on 19/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushControllerDataEntryCell.h"

@class PushTextEntryCell;

@interface UINoteView : UITextView
{
}


@end


@interface PushTextViewController : UIViewController<UIScrollViewDelegate,UITextViewDelegate> {
	
	
@private
	UIBarButtonItem *btnSave;
	UINoteView  * txtValue;
	
	PushTextEntryCell *_cell;

}
@property (nonatomic) IBOutlet UIBarButtonItem *btnSave;
@property (nonatomic) IBOutlet UINoteView  * txtValue;

- (IBAction) saveValue: (id)sender;

- (void) initWithCell:(PushTextEntryCell*)cell;

@end 

@interface PushTextEntryCell : PushControllerDataEntryCell {
	
@private
	PushTextViewController *viewController;
    UIImageView *editIcon_;

    UIImage* imgWrite_;
    UIImage* imgEdit_;
    
}

//@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic) IBOutlet PushTextViewController *viewController;
@property (nonatomic) IBOutlet UIImageView * editIcon;

@property (nonatomic,readonly) UIImage * imgWrite;
@property (nonatomic, readonly) UIImage * imgEdit;

@end

