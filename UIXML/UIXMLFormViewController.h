//
//  TableViewController.h
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXMLFormViewControllerDelegate.h"

#define HEADER_IN_SECTION_LABEL_TAG 1

@class BaseDataEntryCell;

@interface UIXMLFormViewController : UITableViewController<UIXMLFormViewControllerDelegate> {

@protected 
	NSArray *tableStructure;
		
@private	
	
	NSString *resource; 
	
	BaseDataEntryCell *dataEntryCell;
	UIView *_headerInSection;
}

@property (nonatomic,readonly) NSString *resource;
@property (nonatomic,retain) IBOutlet BaseDataEntryCell *dataEntryCell;	
@property (nonatomic,retain) IBOutlet UIView *headerInSection;	


- (id)initFromFile:(NSString*)resource registerNotification:(BOOL)registerNotification;
- (void)loadFromFile:(NSString*)resource;

-(void)registerControEditingNotification;
-(void)unregisterControEditingNotification;

-(void)cellControlDidEndEditingNotify:(NSNotification *)notification;

-(NSString*)getStringInSection:(NSInteger)section;

-(BaseDataEntryCell*)cellForIndexPath:(NSUInteger)row section:(NSUInteger)section;
@end

@interface UIXMLFormViewControllerEx : UIXMLFormViewController {
	
	
	id<UIXMLFormViewControllerDelegate> delegate;
	
}

@property (nonatomic,assign)  id<UIXMLFormViewControllerDelegate> delegate;

@end

