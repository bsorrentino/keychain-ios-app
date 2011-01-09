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
	UISegmentedControl *segmentedField;
	NSArray *_segmentKeys;
}

-(void)valueChanged:(id)sender;

@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic,retain) IBOutlet UISegmentedControl *segmentedField;

@end

