//
//  FormData.h
//  TableViewDataEntry
//
//  Created by Bartolomeo Sorrentino on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FormData : NSObject {

@private
	NSMutableDictionary *_model;

}

@property (nonatomic,readonly) NSMutableDictionary *model;

@end
