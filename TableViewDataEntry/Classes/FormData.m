//
//  FormData.m
//  TableViewDataEntry
//
//  Created by Bartolomeo Sorrentino on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FormData.h"


@implementation FormData

@synthesize model;

- (id) init {

	_model = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (id) model {
	
	return _model;
}
@end
