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
@private
    UIColor *lineColor;


}


@end


@interface PushTextViewController : UIViewController<UIScrollViewDelegate,UITextViewDelegate> {
	
	
@private
	UIBarButtonItem *btnSave;
	UINoteView  * txtValue;
	
	PushTextEntryCell *_cell;

}
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnSave;
@property (nonatomic,retain) IBOutlet UINoteView  * txtValue;

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
@property (nonatomic,retain) IBOutlet PushTextViewController *viewController;
@property (nonatomic,retain) IBOutlet UIImageView * editIcon;

@property (nonatomic,readonly) UIImage * imgWrite;
@property (nonatomic, readonly) UIImage * imgEdit;

@end

