//
//  WETouchableView.h
//  WEPopover
//
//  Created by Werner Altewischer on 12/21/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WETouchableView;

/**
  * @brief delegate to receive touch events
  */
@protocol WETouchableViewDelegate<NSObject>

- (void)viewWasTouched:(WETouchableView *)view;

@end

/**
 * @brief View that can handle touch events and/or disable touch forwording to child views
 */
@interface WETouchableView : UIView {
	BOOL touchForwardingDisabled;
#if !__has_feature(objc_arc)
	id <WETouchableViewDelegate> delegate;
#else
	id <WETouchableViewDelegate> __unsafe_unretained delegate;
#endif
	NSArray *passthroughViews;
	BOOL testHits;
}

@property (nonatomic, assign) BOOL touchForwardingDisabled;
#if !__has_feature(objc_arc)
@property (nonatomic, assign) id <WETouchableViewDelegate> delegate;
#else
@property (nonatomic, unsafe_unretained) id <WETouchableViewDelegate> delegate;
#endif
@property (nonatomic, copy) NSArray *passthroughViews;

@end
