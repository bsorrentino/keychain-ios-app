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

//
// UIXMLFormViewController
//
@interface UIXMLFormViewController : UITableViewController<UIXMLFormViewControllerDelegate> {

@protected 
	NSArray *tableStructure;
		
@private	
	
	NSString *__unsafe_unretained resource; 
	
	BaseDataEntryCell *dataEntryCell;
	UIView *_headerInSection;
}

@property (unsafe_unretained, nonatomic,readonly) NSString *resource;
@property (nonatomic) IBOutlet BaseDataEntryCell *dataEntryCell;	
@property (nonatomic) IBOutlet UIView *headerInSection;	


- (id)initFromFile:(NSString*)resource registerNotification:(BOOL)registerNotification;
- (void)loadFromFile:(NSString*)resource;

-(void)registerControEditingNotification;
-(void)unregisterControEditingNotification;

-(void)cellControlDidEndEditingNotify:(NSNotification *)notification;

-(NSString*)getStringInSection:(NSInteger)section;

-(BaseDataEntryCell*)cellForIndexPath:(NSUInteger)row section:(NSUInteger)section;
@end



//
//  UIXMLFormViewControllerEx
// 
//  add a delegate 
// 
@interface UIXMLFormViewControllerEx : UIXMLFormViewController {
	
	
	id<UIXMLFormViewControllerDelegate> __unsafe_unretained delegate;
	
}

@property (nonatomic,unsafe_unretained)  id<UIXMLFormViewControllerDelegate> delegate;

@end

