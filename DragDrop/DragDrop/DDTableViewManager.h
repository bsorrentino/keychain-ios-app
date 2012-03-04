//
//  DDManager.h
//  DragDrop
//
//  Created by Bartolomeo Sorrentino on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _USE_ARC  0


#if _USE_ARC == 1 

#   define WEAK __weak

#else 

#   define WEAK 

#endif


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
    
    WEAK id<DDTableViewManagerDelegate> delegate;
    
    dispatch_queue_t scrolling_queue;
    
}

@property (nonatomic,readonly,retain) NSIndexPath *source;
@property (nonatomic,readonly,retain) UITableView *tableView;

#if _USE_ARC == 1 
@property (nonatomic,weak) id<DDTableViewManagerDelegate> delegate;
#else
@property (nonatomic,assign) id<DDTableViewManagerDelegate> delegate;
#endif
@property (nonatomic,assign) BOOL enabled;

- (id)initFromTableView:(UITableView *)view;

 
@end




