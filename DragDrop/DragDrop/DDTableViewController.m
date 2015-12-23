//
//  DDTableViewController.m
//  DragDrop
//
//  Created by softphone on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DDTableViewController.h"
#import <QuartzCore/CALayer.h>


@interface DDTableViewController(Private)

-(UITableViewCell *)findTappedCell:(UIGestureRecognizer *)recognizer ;

-(void)beginDrag:recognizer:(UIGestureRecognizer *)recognizer;
-(void)moveDrag:recognizer:(UIGestureRecognizer *)recognizer;
-(void)endDrag:recognizer:(UIGestureRecognizer *)recognizer;
-(void)drop;


-(UIView *)dragViewFromCell:(UITableViewCell *)cell recognizer:(UIGestureRecognizer *)recognizer;
-(UIView *)getDragView;
-(UIView *)removeDragView;

@end

@implementation DDTableViewController

@synthesize longPressRecognizer;
@synthesize panRecognizer;


#pragma mark - Private 

-(UIView *)dragViewFromCell:(UITableViewCell *)cell recognizer:(UIGestureRecognizer *)recognizer
{

    if (cell == nil ) {
        return nil;
    }
    
    CGPoint tPoint = [recognizer locationInView:cell]; 
    
    
    NSLog(@"CellX %lf CY %lf", tPoint.x, tPoint.y);
    
    
    UIGraphicsBeginImageContext(cell.bounds.size);
    
    
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageView * newView = [[UIImageView alloc] initWithImage:viewImage];
    newView.tag = 99;
    
    [self.tableView addSubview:newView];
    
    //[newView release]; // Forbidden by ARC
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    newView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    [UIView commitAnimations];
    tPoint = [cell convertPoint:tPoint toView:self.tableView];
    
    newView.center = tPoint;
    
    return newView;
    
}

-(UIView *)getDragView {
    return [self.tableView viewWithTag:99];
}

-(UIView *)removeDragView {
    
    UIView *dragView = [self getDragView];
    if (dragView != nil ) {
        [dragView removeFromSuperview];
    }
    return dragView;
}

-(UITableViewCell *)findTappedCell:(UIGestureRecognizer *)recognizer {
    
    CGPoint tPoint = [recognizer locationInView:self.tableView];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
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
    dragStarted_ = YES;
    
    UITableViewCell *cell = nil;
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];

    
    if (selectedIndexPath==nil) {
        
        
        cell = [self findTappedCell:recognizer];

    }
    else {
        
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
        
        cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        
    }
    

    [self dragViewFromCell:cell recognizer:recognizer];
 }

-(void)moveDrag:(UIGestureRecognizer *)recognizer 
{

    UIView *dragView = [self getDragView];
    
    if (dragView == nil ) return;

    
    CGPoint tPoint = [recognizer locationInView:self.tableView]; 
    
    NSLog(@"CellX %lf CY %lf", tPoint.x, tPoint.y);
    
    
    dragView.center = tPoint;
    
    
}

-(void)endDrag:(UIGestureRecognizer *)recognizer {
    
    UIView *dragView = [self getDragView];
    
    if (dragView == nil ) return;
    
    dragStarted_ = NO;
    
    CGPoint tPoint = [recognizer locationInView:self.tableView]; 
    
    NSLog(@"CellX %lf CY %lf", tPoint.x, tPoint.y);
        
    dragView.center = tPoint;

    [UIView transitionWithView:dragView 
                      duration:0.4 
                       options:UIViewAnimationCurveEaseIn 
                    animations:^{ 
                        dragView.transform = CGAffineTransformMakeScale(0.2, 0.2); 
                    }
                    completion:^(BOOL finished){ 
                        [self drop];
                    } ];
    /*
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(drop)];
    
    dragView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    [UIView commitAnimations];
    */
}

- (void)drop {
    
    [self removeDragView];

}

#pragma mark Actions

- (IBAction)pan:(id)sender {

    switch (((UIGestureRecognizer *)sender).state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Move Drag Became");
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"Move Drag Changed");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self moveDrag:sender];
            });
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

- (IBAction)longPress:(id)sender {
    
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
            dragStarted_ = NO;
            break;
        default:
            break;
    }
}


#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // CONFLICT RESOLUTION
    //[self.longPressRecognizer requireGestureRecognizerToFail:self.panRecognizer];
    
    dragStarted_ = NO;
    
    self.longPressRecognizer.allowableMovement = 2.0f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"CELL [%d]", indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath [%@]", indexPath);
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - UIGestureRecognizerDelegate 

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    if( [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ) return YES;
    
    return ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && dragStarted_ );
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
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end
