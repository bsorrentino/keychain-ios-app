    //
//  KeyTableViewCell.m
//  KeyChain
//
//  Created by softphone on 09/08/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "KeyTableViewCell.h"
#import "KeyEntity+Cryptor.h"

@interface KeyTableViewCell ()

@property (nonatomic,readonly,getter=getImageCached) UIImage *imageCached;

@end

@implementation KeyTableViewCell
@synthesize imageCached;
@synthesize entity;

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.entity = nil;
        //self.imageView.image = self.imageCached;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.direction = ZKRevealingTableViewCellDirectionRight;

    }
    return self;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.entity = nil;
        //self.imageView.image = self.imageCached;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.direction = ZKRevealingTableViewCellDirectionRight;
    }
    return self;
}

- (UIImage *)getImageCached
{
    //return [UIImage imageNamed:@"key22x22.png"];
    return [UIImage imageNamed:@"swipeR@18x24.png"];
    
}

// These methods can be used by subclasses to animate additional changes to the cell when the cell is changing state
// Note that when the cell is swiped, the cell will be transitioned into the UITableViewCellStateShowingDeleteConfirmationMask state,
// but the UITableViewCellStateShowingEditControlMask will not be set.
- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    
    NSLog(@"willTransitionToState [%d]", state);
    
    if( state & UITableViewCellStateShowingEditControlMask ) {
        [self.backView setHidden:YES];
        [self.imageView setHidden:YES];
        self.imageView.image = nil;
        self.direction = ZKRevealingTableViewCellDirectionNone;
        
    }
    else if (state & UITableViewCellStateShowingDeleteConfirmationMask )  {
        
    }
    else /*if( state & UITableViewCellStateDefaultMask )*/ {

        [self.backView setHidden:NO];
        self.imageView.image = self.imageCached;
        [self.imageView setHidden:NO];
        self.direction = ZKRevealingTableViewCellDirectionRight;
        
    }
    
    [super willTransitionToState:state];
}
//- (void)didTransitionToState:(UITableViewCellStateMask)state __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL result = [super gestureRecognizerShouldBegin:gestureRecognizer];

    if( result ) {
        
        __block UILabel *label = (UILabel *)[self.backView viewWithTag:1];
        if( label!=nil ) {

            label.transform = CGAffineTransformMakeScale(0.01, 0.01);
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:0
                             animations:^() {
                                 label.transform = CGAffineTransformMakeRotation( -M_PI );
                             }
                             completion:^(BOOL finished) {
                                 if( !finished) return;
                                 label.text = [entity getPasswordDecrypted];

                             }];

    /*
            double delayInSeconds = .25;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UILabel *label = (UILabel *)[self.backView viewWithTag:1];
                    if( label != nil )
                        label.text = [entity getPasswordDecrypted];
                    
                });
            });
    */
        }
    }
    
	return result;
}

@end
