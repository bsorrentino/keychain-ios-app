//
//  SwitchDataEntryCell.h
//  TableViewDataEntry
//
//  Created by softphone on 20/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIXML.h"
#import "BaseDataEntryCell.h"


@interface SwitchDataEntryCell : BaseDataEntryCell {

	UISwitch *__UIXML_WEAK switchField;
}

//@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (UIXML_WEAK,nonatomic) IBOutlet UISwitch *switchField;
@end
