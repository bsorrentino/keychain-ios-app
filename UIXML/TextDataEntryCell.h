//
//  TextDataEntryCell.h
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDataEntryCell.h"

@interface TextDataEntryCell : BaseDataEntryCell <UITextFieldDelegate> {
	UITextField *textField;
}

@property (nonatomic) IBOutlet UITextField *textField;

@end
