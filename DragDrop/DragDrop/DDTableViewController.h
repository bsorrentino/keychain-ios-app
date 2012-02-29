//
//  DDTableViewController.h
//  DragDrop
//
//  Created by softphone on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTableViewController : UITableViewController<UIGestureRecognizerDelegate> {
    
@private
    
    BOOL dragStarted_;
    
    UILongPressGestureRecognizer *longPressRecognizer;
    UIPanGestureRecognizer *panRecognizer;
    
}


@property (nonatomic,retain) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic,retain) IBOutlet UIPanGestureRecognizer *panRecognizer;

- (IBAction)pan:(id)sender;
- (IBAction)longPress:(id)sender;



@end

