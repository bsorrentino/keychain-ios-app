//
//  DDManager.h
//  DragDrop
//
//  Created by Bartolomeo Sorrentino on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DDTableViewManagerDelegate <NSObject>

@required

@optional

- (BOOL) possibleDropTo:(NSIndexPath *)target;
- (BOOL) beginDrag:(NSIndexPath *)source;
- (void) dropTo:(NSIndexPath *)source target:(NSIndexPath *)target;

@end


@interface DDTableViewManager : NSObject<UIGestureRecognizerDelegate> {

@private

    NSIndexPath *source_;
    
    UILongPressGestureRecognizer *longPressRecognizer_;
    UIPanGestureRecognizer *panRecognizer_;

    UITableView *tableView_;
    
    id<DDTableViewManagerDelegate> delegate;
}


@property (nonatomic,readonly,retain) NSIndexPath *source;
@property (nonatomic,readonly,retain) UITableView *tableView;
@property (nonatomic,assign) id<DDTableViewManagerDelegate> delegate;
@property (nonatomic,assign) BOOL enabled;

- (id)initFromTableView:(UITableView *)view;

 
@end
