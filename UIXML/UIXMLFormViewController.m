//
//  TableViewController.m
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import "UIXMLFormViewController.h"
#import "UIXMLFormViewControllerDelegate.h"
#import "BaseDataEntryCell.h"
#import "TextDataEntryCell.h"
#import "PushControllerDataEntryCell.h"

@implementation UIXMLFormViewController

@synthesize resource;
@synthesize dataEntryCell;
@synthesize headerInSection=_headerInSection;


#pragma mark custom methods

- (id)initFromFile:(NSString*)file registerNotification:(BOOL)registerNotification {
	
	id result = [super initWithStyle:UITableViewStyleGrouped];
	
	if (result!=nil) {
		[self loadFromFile:file];
	}

	if(registerNotification ) [self registerControEditingNotification];

	return result;
}

- (void)loadFromFile:(NSString*)file {
	
	if (tableStructure!=nil) {
		return ;
	}
	
	resource = [[NSBundle mainBundle] pathForResource:file ofType:nil];
	
    tableStructure = [[NSArray arrayWithContentsOfFile:resource] retain];

	[self registerControEditingNotification];
	
	return ;
}

-(NSString*)getStringInSection:(NSInteger)section {
	
	NSArray *sectionInfo = [tableStructure objectAtIndex:section];
	
	NSDictionary *sectionInfoData = [sectionInfo objectAtIndex:0];
	
	return [sectionInfoData objectForKey:@"label"];
	
}

#pragma mark -
#pragma mark UIXMLFormViewControllerDelegate

-(void)cellControlDidEndEditing:(BaseDataEntryCell *)cell {

}


-(void)cellControlDidInit:(BaseDataEntryCell *)cell {
	
}


#pragma mark -
#pragma mark Editing control

-(void)registerControEditingNotification {

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(cellControlDidEndEditingNotify:)
		name:CELL_ENDEDIT_NOTIFICATION_NAME
		object:nil];      
	
}

-(void)unregisterControEditingNotification {
	[[NSNotificationCenter defaultCenter]
		removeObserver:self
		name:CELL_ENDEDIT_NOTIFICATION_NAME
		object:nil];      
}


#pragma mark -
#pragma mark Editing control

-(void)cellControlDidEndEditingNotify:(NSNotification *)notification
{
	NSLog(@"cellControlDidEndEditingNotify");
	
	//NSIndexPath *cellIndex = (NSIndexPath *)[notification object];
	//BaseDataEntryCell *cell = (BaseDataEntryCell *)[self.tableView cellForRowAtIndexPath:cellIndex];

	BaseDataEntryCell *cell = (BaseDataEntryCell *)[notification object];
	
	[self cellControlDidEndEditing:cell];
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
}

- (void)viewDidUnload {
	[self unregisterControEditingNotification];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}





/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if (tableStructure==nil) {
		return 0;
	}
	
    NSInteger section =  tableStructure.count;
	
	return section;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (tableStructure==nil) {
		return 0;
	}
	
	NSArray *sectionInfo = [tableStructure objectAtIndex:section];
	NSArray *sectionData = [sectionInfo objectAtIndex:1];
	
    return [sectionData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    // fixed font style. use custom view (UILabel) if you want something different
	
	return [self getStringInSection:section];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //static NSString *CellIdentifier = @"Cell";
       
    //NSDictionary *cellData = [tableStructure objectAtIndex:indexPath.row];

	NSLog( @"section[%d] row [%d]", indexPath.section, indexPath.row );

	NSArray *sectionInfo = [tableStructure objectAtIndex:indexPath.section];

#ifdef _TRACE	
	NSLog( @"sectionInfo [%@]", sectionInfo );
#endif

	NSArray *sectionData = [sectionInfo objectAtIndex:1];
	
#ifdef _TRACE	
	NSLog( @"sectionData [%@]", sectionData );
#endif
	
	NSDictionary *cellData = [sectionData objectAtIndex:indexPath.row];
	
#ifdef _TRACE	
	NSLog( @"cellData [%@]", cellData );
#endif
	
	NSString *dataKey = [cellData objectForKey:@"DataKey"];
	NSString *cellType = [cellData objectForKey:@"CellType"];
	
	NSLog( @"DataKey[%@] CellType [%@]", dataKey, cellType );
	
	BaseDataEntryCell *cell = (BaseDataEntryCell *)[tableView dequeueReusableCellWithIdentifier:cellType];
	if (cell == nil) {
		
		[[NSBundle mainBundle] loadNibNamed:cellType owner:self options:nil];
		
		cell = dataEntryCell;
		self.dataEntryCell = nil;
	
		[cell init:self datakey:dataKey label:[cellData objectForKey:@"Label"] cellData:cellData];
		
		//cell = [[[NSClassFromString(cellType) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellType] autorelease];

		[self cellControlDidInit:cell];
		
	}
	else {
		[self cellControlDidInit:cell];
	}

	/*
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	// Impostiamo la datakey della cella
	cell.dataKey = dataKey;
	
	cell.textLabel.text = [cellData objectForKey:@"Label"];
	*/	
	
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


 

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if( self.navigationController == nil ) return;
	
	NSLog( @"section[%d] row [%d]", indexPath.section, indexPath.row );
	
	NSArray *sectionInfo = [tableStructure objectAtIndex:indexPath.section];

#ifdef _TRACE		
	NSLog( @"sectionInfo [%@]", sectionInfo );
#endif
	
	NSArray *sectionData = [sectionInfo objectAtIndex:1];
	
#ifdef _TRACE		
	NSLog( @"sectionData [%@]", sectionData );
#endif
	
	NSDictionary *cellData = [sectionData objectAtIndex:indexPath.row];
	
#ifdef _TRACE	
	NSLog( @"cellData [%@]", cellData );
#endif
	
	NSString *dataKey = [cellData objectForKey:@"DataKey"];
	NSString *cellType = [cellData objectForKey:@"CellType"];

	NSLog( @"DataKey[%@] CellType [%@]", dataKey, cellType );

	BaseDataEntryCell *cell = (BaseDataEntryCell *)[tableView cellForRowAtIndexPath:indexPath];
	if( [cell isKindOfClass:[PushControllerDataEntryCell class]] ) {
	
		PushControllerDataEntryCell *pushCell = (PushControllerDataEntryCell *)cell;
		
		// Navigation logic may go here. Create and push another view controller.
		
		UIViewController *detailViewController = [pushCell viewController:cellData];
		
		[self.navigationController pushViewController:detailViewController animated:YES];
		
		//[detailViewController release];
		
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	NSString * text = [self getStringInSection:section];
	
	[[NSBundle mainBundle] loadNibNamed:@"DefaultHeaderInSection" owner:self options:nil];
	
	UIView *h = _headerInSection; _headerInSection = nil;

	h.backgroundColor = self.view.backgroundColor;

	UILabel * label = (UILabel*)[h viewWithTag:HEADER_IN_SECTION_LABEL_TAG];
	
	label.text = text;
	
	return h;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[tableStructure release];
    [super dealloc];
}


@end

#pragma mark UIXMLFormViewControllerEx implementation

@implementation UIXMLFormViewControllerEx

@synthesize delegate;

-(void)cellControlDidEndEditing:(BaseDataEntryCell *)cell {
	if( delegate!=nil  ) {
		[delegate cellControlDidEndEditing:cell];
	}
	
}


-(void)cellControlDidInit:(BaseDataEntryCell *)cell {
	
	if( delegate!=nil ) {
		[delegate cellControlDidInit:cell];
	}
	
}

@end


