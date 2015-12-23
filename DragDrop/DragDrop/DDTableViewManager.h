//
//  DDManager.h
//  DragDrop
//
//  Created by Bartolomeo Sorrentino on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifndef DD_STRONG
#   if __has_feature(objc_arc)
#       define DD_STRONG strong
#   else
#       define DD_STRONG retain
#   endif
#   define __DD_STRONG
#endif

#ifndef DD_WEAK
#if __has_feature(objc_arc_weak)
#   define DD_WEAK weak
#   define __DD_WEAK __weak
#elif __has_feature(objc_arc)
#   define DD_WEAK unsafe_unretained
#   define __DD_WEAK __unsafe_unretained
#else
#   define DD_WEAK assign
#   define __DD_WEAK
#endif
#endif

#define __BLOCKSELF \
__typeof(self) __weak __self = self

@protocol DDTableViewManagerDelegate <NSObject>

@required

@optional

- (BOOL) possibleDropTo:(NSIndexPath *)target;
- (BOOL) beginDrag:(NSIndexPath *)source;
- (void) dropTo:(NSIndexPath *)source target:(NSIndexPath *)target;

@end


@interface DDTableViewManager : NSObject<UIGestureRecognizerDelegate> 
@property (nonatomic,readonly) NSIndexPath *source;
@property (nonatomic,readonly) UITableView *tableView;

#if __has_feature(objc_arc)
@property (nonatomic,weak) id<DDTableViewManagerDelegate> delegate;
#else
@property (nonatomic,unsafe_unretained) id<DDTableViewManagerDelegate> delegate;
#endif
@property (nonatomic,assign) BOOL enabled;

- (id)initFromTableView:(UITableView *)view;

 
@end




