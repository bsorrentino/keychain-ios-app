//
//  UIXMLFormViewControllerDelegate.h
//  TableViewDataEntry
//
//  Created by Bartolomeo Sorrentino on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseDataEntryCell;

@protocol UIXMLFormViewControllerDelegate 

-(void)cellControlDidEndEditing:(BaseDataEntryCell *)cell;

@optional
-(void)cellControlDidInit:(BaseDataEntryCell *)cell;


@end
