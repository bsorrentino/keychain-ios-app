//
//  ListDataEntryCell.m
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 8/30/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "ListDataEntryCell.h"


@implementation ListDataEntryCell

@synthesize listViewController=listViewController_;

-(id)init:(UIXMLFormViewController*)controller datakey:(NSString*)key label:(NSString*)label cellData:(NSDictionary*)cellData
{
    if( [super init:controller datakey:key label:label cellData:cellData]!=nil ) {
         //self.detailTextLabel.text = @"test1";
    }
    
    return self;
    
}


-(UIViewController *)viewController:(NSDictionary*)cellData {
    
    return self.listViewController;
}

@end



@interface ListDataViewController(Private) 

- (void)insertNewObject;


@end


@implementation ListDataViewController


#pragma mark - private method


- (void) insertNewObject
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle: @"Enter New Item" 
						  message:@"Specify the Item Name"
						  delegate:self
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:@"OK", nil];
    
	// Name field
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
    tf.tag = 100;
    tf.placeholder = @"name";
    [tf setBackgroundColor:[UIColor whiteColor]]; 
	tf.clearButtonMode = UITextFieldViewModeWhileEditing;
	tf.keyboardType = UIKeyboardTypeAlphabet;
	tf.keyboardAppearance = UIKeyboardAppearanceAlert;
	tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
	tf.autocorrectionType = UITextAutocorrectionTypeNo;
    [tf becomeFirstResponder];
    [alert addSubview:tf];	

    //CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
    //[alert setTransform:transform];
    
	[alert show];
    
    [tf release];
    [alert release];
	
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1 ) {
        UITextField *tf = (UITextField*)[alertView viewWithTag:100];
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[data_ count] inSection:0];
        NSArray *indexs = [[NSArray alloc] initWithObjects:indexPath, nil];
        
        [data_ addObject:tf.text];
        //[self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexs withRowAnimation:YES];
        //[self.tableView endUpdates];
        
        [indexs release];
    }
    //[alertView release];
}



#pragma mark - Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [data_ release];
    
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
    // Do any additional setup after loading the view from its nib.
    
    // Add Edit Button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
   
    data_ = [[NSMutableArray alloc] initWithObjects:@"Item1", @"Item2", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [data_ count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ListDataEntryCell"];

    if( cell==nil )  {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ListDataEntryCell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    NSString *value = [data_ objectAtIndex:indexPath.row];
    
    cell.textLabel.text = value;
    cell.detailTextLabel.text = value;
    
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
        {
            NSArray *indexs = [[NSArray alloc] initWithObjects:indexPath, nil];
            [data_ removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:indexs withRowAnimation:YES];     
            [indexs release];
            break;
        }
        break;
        case UITableViewCellEditingStyleInsert:
            break;
        case UITableViewCellEditingStyleNone: 
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
        //[_cell postEndEditingNotification];
        
        [self.navigationController popViewControllerAnimated:YES];
}



@end
