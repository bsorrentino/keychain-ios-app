//
//  KeyTableViewCell.m
//  KeyChain
//
//  Created by softphone on 09/08/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "KeyTableViewCell.h"

@interface KeyTableViewCell ()

@property (nonatomic,readonly,getter=getImageCached) UIImage *imageCached;

@end

@implementation KeyTableViewCell
@synthesize imageCached;

#pragma mark - Lifecycle

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageView.image = self.imageCached;
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
        self.imageView.image = self.imageCached;
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
    
    switch (state) {
        case UITableViewCellStateShowingEditControlMask:
            [self.backView setHidden:YES];
            [self.imageView setHidden:YES];
            self.imageView.image = nil;
            self.direction = ZKRevealingTableViewCellDirectionNone;
            
            break;
        case UITableViewCellStateShowingDeleteConfirmationMask:
            break;
        default: // UITableViewCellStateDefaultMask
            [self.backView setHidden:NO];
            self.imageView.image = self.imageCached;
            [self.imageView setHidden:NO];
            self.direction = ZKRevealingTableViewCellDirectionRight;
            break;
    }
    
    [super willTransitionToState:state];
}
//- (void)didTransitionToState:(UITableViewCellStateMask)state __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);


@end
