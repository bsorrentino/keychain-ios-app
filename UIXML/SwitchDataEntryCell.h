//
//  SwitchDataEntryCell.h
//  TableViewDataEntry
//
//  Created by softphone on 20/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDataEntryCell.h"


@interface SwitchDataEntryCell : BaseDataEntryCell {

	UISwitch *switchField;
}

//@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic) IBOutlet UISwitch *switchField;
@end
