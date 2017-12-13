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
    //NSMutableDictionary *__UIXML_STRONG dataEntryCells;
}

@property (UIXML_WEAK, nonatomic,readonly) NSString * _Nullable resource;
@property (UIXML_WEAK, nonatomic) IBOutlet BaseDataEntryCell * _Nullable dataEntryCell;



- (id _Nonnull )initFromFile:(NSString*_Nonnull)resource registerNotification:(BOOL)registerNotification;

- (void)loadFromFile:(NSString*_Nonnull)resource;
- (void)loadFromArray:(NSArray *_Nonnull)array;

-(void)registerControEditingNotification;
-(void)unregisterControEditingNotification;

-(void)cellControlDidEndEditingNotify:(NSNotification *_Nonnull)notification;

-(NSString*_Nonnull)getStringInSection:(NSInteger)section;

-(BaseDataEntryCell*_Nullable)cellForIndexPath:(NSUInteger)row section:(NSUInteger)section;

// Cell Factory Method
- (BaseDataEntryCell * _Nullable)tableView:(UITableView *_Nonnull)tableView cellFromType:(NSString *_Nonnull)cellType cellData:(NSDictionary*_Nonnull)cellData;

@end



//
//  UIXMLFormViewControllerEx
// 
//  add a delegate 
// 
@interface UIXMLFormViewControllerEx : UIXMLFormViewController {
	
	
	id<UIXMLFormViewControllerDelegate> __UIXML_WEAK delegate;
	
}

@property (nonatomic,UIXML_WEAK)  id<UIXMLFormViewControllerDelegate> _Nullable delegate;

@end

