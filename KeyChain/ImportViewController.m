//
//  ImportViewController.m
//  KeyChain
//
//  Created by softphone on 09/10/11.
//  Copyright 2011 SOFTPHONE. All rights reserved.
//

#import "ImportViewController.h"
#import "PersistentAppDelegate.h"
#import "KeyChainAppDelegate.h"
#import "KeyEntity.h"
#import "WaitMaskController.h"

@interface ImportViewController(Private)

- (KeyChainAppDelegate *) appDelegate;
- (void)listFiles;
- (void)showPopup;
- (void)importReplacingAll:(NSString *)fileName;
@end


@implementation ImportViewController

@synthesize delegate;

#pragma mark - ImportViewController UIAlertViewDelegate implementation 

/*
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView;

- (void)willPresentAlertView:(UIAlertView *)alertView;  // before animation and showing view
- (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
*/


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {  // after animation
    
    if( buttonIndex == 1 ) { // Delete File  

        NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
        
        if (indexPath==nil )  {
            return;
        }
        
        NSString *fileName = [fileArray_ objectAtIndex:indexPath.row];
       
        
        BOOL expandTilde = YES;
        NSSearchPathDirectory destination = NSDocumentDirectory;
        
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(destination, NSUserDomainMask, expandTilde) lastObject];
        
        NSString *targetPath = [documentDirectory stringByAppendingPathComponent:fileName];
        
        NSError * error;
        
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error ];
        
        if( !result )
            [KeyChainAppDelegate  showErrorPopup:error];
        
    }
    
    

    [self.navigationController popViewControllerAnimated:YES];    
}

#pragma mark - ImportViewController private methods 

- (KeyChainAppDelegate *)appDelegate {
    
    return (KeyChainAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)importReplacingAll:(NSString *)fileName {
    
    if( self.delegate == nil ) return;

    BOOL expandTilde = YES;
    
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    WaitMaskController *wait = [[WaitMaskController alloc] init ] ;

    @try { 

        [wait mask:@"Import file ...."];
        
        //NSSearchPathDirectory destination = NSLibraryDirectory;
        NSSearchPathDirectory destination = NSDocumentDirectory;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(destination, NSUserDomainMask, expandTilde);
        
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *inputPath = [documentDirectory stringByAppendingPathComponent:fileName];
        NSLog(@"Document paths[0]=[%@]", inputPath);
        
        //NSInputStream *is = [NSInputStream inputStreamWithFileAtPath:inputPath];
        //id result = [NSPropertyListSerialization propertyListWithStream:is options:NSPropertyListImmutable format:nil error:&error ];
        
        wait.message = @"reading .....";
        
        NSError *errorReadingFile;
        NSData *data = [NSData dataWithContentsOfFile:inputPath options:NSDataReadingUncached error:&errorReadingFile];

        if (data== nil ) {
            
            [KeyChainAppDelegate showErrorPopup:errorReadingFile];
            return;
        }
        
        NSError *error;
        NSArray *result = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&error ];
        
        if (result== nil ) {
            
            [KeyChainAppDelegate showErrorPopup:error];
            return;
        }
        
        NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
        
        wait.message = @"deleting keys .....";

        NSArray *keyList = [self.delegate fetchedObjects];
        
        for (KeyEntity *e in keyList ) {
            
            NSLog(@"deleting [%@]", e.mnemonic);
            [context deleteObject:e];
        }
        
        
        wait.message = @"adding keys .....";
         
        for( NSInteger i = 1; i < [result count]; ++i ) {
            
            KeyEntity * entity = [[[KeyEntity alloc] initWithEntity:[delegate entityDescriptor] insertIntoManagedObjectContext:context] autorelease];
            
            NSDictionary *d = [result objectAtIndex:i];
            [entity fromDictionary:d];
            
            NSLog(@"mnemonic = [%@]", entity.mnemonic);
        }
        
        [[self appDelegate] saveContext];
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Import" 
                                                        message:@"Completed!"
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:@"Delete File", nil] autorelease];
        [alert show];
    
    }
    @finally {
        
        [wait unmask];
        
        [pool drain];   
        
    }
}

-(void)listFiles {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    @try {
        BOOL expandTilde = YES;
        NSSearchPathDirectory destination = NSDocumentDirectory;
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(destination, NSUserDomainMask, expandTilde);
        
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(destination, NSUserDomainMask, expandTilde) lastObject];
        
        NSError *error;
        
        //NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:&error];
        
        NSArray * filteredArray = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.plist'"]];    
        
        
        fileArray_ = [[filteredArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
            
            return [obj2 localizedCaseInsensitiveCompare:obj1 ];
        }] retain];
    }
    @finally {
        [pool drain];
    }
    
}

- (void)showPopup {
   
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Import Options" 
                                                    delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                                    destructiveButtonTitle:@"Replace All" 
                                                    otherButtonTitles:@"Only Add New", @"Add and Update", nil];
    [sheet showInView:self.tableView];
}

#pragma mark - ImportViewController UIActionSheetDelegate implementation


// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
    
    if (indexPath==nil )  {
        return;
    }
    
    NSString *fileName = [fileArray_ objectAtIndex:indexPath.row];
    
    NSLog(@"clickedButtonAtIndex [%d] [%@]", buttonIndex, fileName );
    
    switch (buttonIndex) {
        case 0:
            [self importReplacingAll:fileName];
            break;
            
        default:
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet { // before animation and showing view
    
    for (UIView* view in [actionSheet subviews])
    {
        NSLog(@"class [%@] tag [%d]", [[view class] description], view.tag );
        
        if( view.tag ==2 || view.tag == 3 ) {
            
                [view performSelector:@selector(setEnabled:) withObject:NO];        
        }
/*        
        if ([[[view class] description] isEqualToString:@"UIThreePartButton"])
        {
            if ([view respondsToSelector:@selector(title)])
            {
                NSString* title = [view performSelector:@selector(title)];
                if ([title isEqualToString:@"Button 1"] && [view respondsToSelector:@selector(setEnabled:)])
                {
                    [view performSelector:@selector(setEnabled:) withObject:NO];
                }
            }
        }
 */
    }
        
}

/*

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet;

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet;  // after animation

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
*/

#pragma mark - ImportViewController initialization 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [fileArray_ release];
    [super dealloc];
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

    self.title = @"Import Key List";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self listFiles];
    [self.tableView reloadData];
    
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
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return (fileArray_ ==nil ) ? 0 : [fileArray_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ImportCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSString * fileName = [fileArray_ objectAtIndex:indexPath.row];
    
    cell.textLabel.text = fileName;
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    [self showPopup];
}

@end
