//
//  DDManager.m
//  DragDrop
//
//  Created by Bartolomeo Sorrentino on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DDTableViewManager.h"

#import <QuartzCore/CALayer.h>


@interface DDTableViewManager(Private)

-(UITableViewCell *)cellForRowAtPoint:(CGPoint)point ;
-(UITableViewCell *)findTappedCell:(UIGestureRecognizer *)recognizer __attribute__((deprecated));;

-(void)beginDrag:recognizer:(UIGestureRecognizer *)recognizer;
-(void)moveDrag:recognizer:(UIGestureRecognizer *)recognizer;
-(void)endDrag:recognizer:(UIGestureRecognizer *)recognizer;
- (void)endDrop:(NSIndexPath *)i;


-(UIView *)dragViewFromCell:(UITableViewCell *)cell recognizer:(UIGestureRecognizer *)recognizer;
-(UIView *)getDragView;
-(UIView *)removeDragView;

- (IBAction)handlePan:(id)sender;
- (IBAction)handleLongPress:(id)sender;

- (void)setSource:(NSIndexPath *)value;

// DELEGATE 
-(BOOL)isPossibleBeginDrag:(NSIndexPath *)i;
-(BOOL)isPossibleDropTo:(NSIndexPath *)i;
-(void)performDropTo:(NSIndexPath *)i;

@end

@implementation DDTableViewManager

@synthesize source=source_;
@synthesize tableView=tableView_;
@synthesize delegate;
@synthesize enabled;

#pragma mark Initialization

- (id)initFromTableView:(UITableView *)view {
    
    if (view == nil ) {
        [NSException raise:NSInvalidArgumentException
                    format:@"view must not be nil"];
    }
    
    if ( (self = [super init]) != nil ) {
        
        [self setSource:nil];
        
        tableView_ = view;
        
        longPressRecognizer_ = [[UILongPressGestureRecognizer alloc ] initWithTarget:self action:@selector(handleLongPress:)];
        longPressRecognizer_.allowableMovement = 2.0f;
        longPressRecognizer_.delegate = self;

        panRecognizer_ = [[UIPanGestureRecognizer alloc ] initWithTarget:self action:@selector(handlePan:) ];
        panRecognizer_.delegate = self;
        
        [tableView_ addGestureRecognizer:longPressRecognizer_];
        [tableView_ addGestureRecognizer:panRecognizer_];
        
        
    }
    
    return self;
}

#pragma mark - Private delegate invokation

-(BOOL)isPossibleBeginDrag:(NSIndexPath *)i {
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(beginDrag:)] ) {
        
        return [self.delegate beginDrag:i];
        
    }
    
    return YES;
}

-(BOOL)isPossibleDropTo:(NSIndexPath *)i {
    
    if ( [source_ compare:i] == NSOrderedSame ) {
        return NO;
    }
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(possibleDropTo:)] ) {
        
        return [self.delegate possibleDropTo:i];
        
    }
    
    return YES;
}

-(void)performDropTo:(NSIndexPath *)from target:(NSIndexPath *)target {
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(dropTo:target:)] ) {
        
        [self.delegate dropTo:from target:target];
        
    }
}

#pragma mark - Private 

- (void)setSource:(NSIndexPath *)value 
{

#if _USE_ARC == 1 
    source_ = value;
#else    
    if( source_ != nil ) {
        [source_ release];   
        source_ = nil;
    }
       
    if( value != nil ) {
       source_ = [value retain];
    }
#endif    
}

-(UIView *)dragViewFromCell:(UITableViewCell *)cell recognizer:(UIGestureRecognizer *)recognizer
{
    if (cell == nil ) {
        return nil;
    }
    
    
    UIGraphicsBeginImageContext(cell.bounds.size);
    
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageView * newView = [[UIImageView alloc] initWithImage:viewImage];
    newView.tag = 99;

    [self.tableView addSubview:newView];
    
#if !_USE_ARC        
    [newView release]; 
#endif        
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         newView.transform = CGAffineTransformMakeScale(.9, .9);
                     } 
                     completion:^(BOOL finished){
                     }];    
    
/*    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    newView.transform = CGAffineTransformMakeScale(1.1, 1.3);
    
    [UIView commitAnimations];
*/
    
    newView.center = cell.center;
    
    return newView;

    
}

-(UIView *)getDragView {
    return [self.tableView viewWithTag:99];
}

-(UIView *)removeDragView {
    
    UIView *dragView = [self getDragView];
    if (dragView != nil ) {
        [dragView removeGestureRecognizer:panRecognizer_];
        [dragView removeFromSuperview];
    }
    return dragView;
}

-(UITableViewCell *)cellForRowAtPoint:(CGPoint)point {

    NSIndexPath * i = [self.tableView indexPathForRowAtPoint:point];
    
    if( i == nil ) return nil;
    
    return [self.tableView cellForRowAtIndexPath:i];
    
}

-(UITableViewCell *)findTappedCell:(UIGestureRecognizer *)recognizer {
    
    
    CGPoint tPoint = [recognizer locationInView:self.tableView];
    
    NSArray * cells = [self.tableView visibleCells];
    for (UITableViewCell * cell in cells)
    {
        if (CGRectContainsPoint(cell.frame, tPoint)) 
        {
            return cell;
            break;
        }
    }
    
    return nil;
}

-(void)beginDrag:(UIGestureRecognizer *)recognizer 
{
    
    
    UITableViewCell *cell = nil;
    
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedIndexPath==nil) {
        
        CGPoint tPoint = [recognizer locationInView:self.tableView];
       
        selectedIndexPath = [self.tableView indexPathForRowAtPoint:tPoint];
        
        if( selectedIndexPath != nil ) {

            cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        }
    }
    else {
                
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
        
        cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        
    }
    
    
    if( ![self isPossibleBeginDrag:selectedIndexPath] ) return;
  
    [self setSource:selectedIndexPath];
    
    
    [self dragViewFromCell:cell recognizer:recognizer];
}

-(void)moveDrag:(UIGestureRecognizer *)recognizer 
{
    
    
    UIView *dragView = [self getDragView];
    
    if (dragView == nil ) return;
    

    CGPoint tPoint = [recognizer locationInView:self.tableView]; 

    NSLog(@"point (%f,%f)", tPoint.x, tPoint.y);
    
    dragView.center = tPoint;
 
    NSIndexPath * i = [self.tableView indexPathForRowAtPoint:tPoint];

    if (i != nil ) {
        
        if( [self isPossibleDropTo:i] ) {
            [self.tableView selectRowAtIndexPath:i animated:TRUE scrollPosition:UITableViewScrollPositionNone];
        }
        //NSArray *indexPathArray = [self.tableView indexPathsForVisibleRows];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:i];

        CGRect frame = cell.frame;

        NSComparisonResult result = [source_ compare:i];
        
        if (result == NSOrderedAscending ) {
            //[self.tableView scrollToRowAtIndexPath:i atScrollPosition:UITableViewScrollPositionBottom animated:YES];  
            
            frame.origin.y += frame.size.height;
            //frame.size.height *= 2;            
            
            [self.tableView scrollRectToVisible:frame animated:YES];
        }
        else if( result == NSOrderedDescending ) {
            //[self.tableView scrollToRowAtIndexPath:i atScrollPosition:UITableViewScrollPositionTop animated:YES];            
            
            frame.origin.y -= frame.size.height;
            //frame.size.height *= 2;
            
            [self.tableView scrollRectToVisible:frame animated:YES];
        }
        
    }

    
}

-(void)endDrag:(UIGestureRecognizer *)recognizer {
    
    UIView *dragView = [self getDragView];
    
    if (dragView == nil ) return;
    
    
    CGPoint tPoint = [recognizer locationInView:self.tableView]; 
    
    NSIndexPath * i = [self.tableView indexPathForRowAtPoint:tPoint];
    
    if (i == nil || ![self isPossibleDropTo:i] ) {
        [self endDrop:nil];
        return;
    }
    
    dragView.center = tPoint;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         dragView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                     } 
                     completion:^(BOOL finished){
                        [self endDrop:i];
                     }];    

//    
// CODE WITHOUT USE OF BLOCK    
//
/*    
    [UIView beginAnimations:nil context:(__bridge_retained void*)i];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endDrop:)];
    
    
    [UIView commitAnimations];
*/    
    
    
}

- (void)endDrop:(NSIndexPath *)i {
    
    [self removeDragView];
    
    if (i != nil ) {
        [self performDropTo:source_ target:i];
    }
    
    [self setSource:nil];
    
}

#pragma mark Enabled

- (BOOL) enabled {
    return (longPressRecognizer_.enabled && panRecognizer_.enabled);

}

- (void) setEnabled:(BOOL)value {
    longPressRecognizer_.enabled = value;
    panRecognizer_.enabled = value;
}

#pragma mark Actions

- (IBAction)handlePan:(id)sender {
    
    switch (((UIGestureRecognizer *)sender).state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Move Drag Became");
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"Move Drag Changed");
            
            [self moveDrag:sender];
        }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Move Drag Ended");
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"Move Drag Cancelled");
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"Move Drag Possible");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"Move Drag Failed");
            break;
        default:
            break;
    }
    
}

- (IBAction)handleLongPress:(id)sender {
    
    switch (((UIGestureRecognizer *)sender).state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Start Drag Became");
            
            [self beginDrag:sender];
            
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"Start Drag Changed");
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Start Drag Ended");
            
            [self endDrag:sender];
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"Start Drag Cancelled");
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"Start Drag Possible");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"Start Drag Failed");
            [self setSource:nil];
            break;
        default:
            break;
    }
}


#pragma mark - UIGestureRecognizerDelegate 

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if( [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ) return YES;
    
    return ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && source_!=nil );
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && 
            [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]);
    
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch ;


- (void)dealloc {
#if !_USE_ARC    
    [source_ release];
    [super dealloc];
#endif
}

@end

