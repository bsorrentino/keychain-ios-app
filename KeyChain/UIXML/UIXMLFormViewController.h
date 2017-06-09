//
//  TableViewController.h
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXML.h"
#import "UIXMLFormViewControllerDelegate.h"

@class BaseDataEntryCell;

//
// UIXMLFormViewController
//
@interface UIXMLFormViewController : UITableViewController<UIXMLFormViewControllerDelegate> {

@protected 
	NSArray *tableStructure;
		
@private	
	
	NSString            *__UIXML_WEAK resource;
	
	BaseDataEntryCell   *__UIXML_WEAK dataEntryCell;
    NSMutableDictionary *__UIXML_STRONG dataEntryCells;
}

@property (UIXML_WEAK, nonatomic,readonly) NSString *resource;
@property (UIXML_WEAK, nonatomic) IBOutlet BaseDataEntryCell *dataEntryCell;



- (id)initFromFile:(NSString*)resource registerNotification:(BOOL)registerNotification;

- (void)loadFromFile:(NSString*)resource;
- (void)loadFromArray:(NSArray *)array;

-(void)registerControEditingNotification;
-(void)unregisterControEditingNotification;

-(void)cellControlDidEndEditingNotify:(NSNotification *)notification;

-(NSString*)getStringInSection:(NSInteger)section;

-(BaseDataEntryCell*)cellForIndexPath:(NSUInteger)row section:(NSUInteger)section;

// Cell Factory Method
- (BaseDataEntryCell *)tableView:(UITableView *)tableView cellFromType:(NSString *)cellType cellData:(NSDictionary*)cellData;

@end



//
//  UIXMLFormViewControllerEx
// 
//  add a delegate 
// 
@interface UIXMLFormViewControllerEx : UIXMLFormViewController {
	
	
	id<UIXMLFormViewControllerDelegate> __UIXML_WEAK delegate;
	
}

@property (nonatomic,UIXML_WEAK)  id<UIXMLFormViewControllerDelegate> delegate;

@end

