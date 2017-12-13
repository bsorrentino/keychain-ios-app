//
//  SegmentedDataEntryCell.h
//  UIXML
//
//  Created by Bartolomeo Sorrentino on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseDataEntryCell.h"

@interface SegmentedDataEntryCell : BaseDataEntryCell {
	
@private	
	UISegmentedControl *__UIXML_WEAK segmentedField;
	NSArray *__UIXML_WEAK _segmentKeys;
}

-(void)valueChanged:(id)sender;

@property (UIXML_WEAK,nonatomic) IBOutlet UISegmentedControl *segmentedField;

@end

