//
//  KeyEntity.m
//  KeyChain
//
//  Created by softphone on 10/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyEntity.h"

@implementation KeyEntity

@synthesize sectionId;

- (void)awakeFromFetch {

    [self setPrimitiveValue:NO forKey:@"isNew"];
	
}

- (void)didSave {

    [self setPrimitiveValue:NO forKey:@"isNew"];
}

-(BOOL)isNew {
	
	BOOL value = [[self primitiveValueForKey:@"isNew"] boolValue];
	NSLog( @"isNew [%d]", value );
	
	return value;
	

}

- (NSString *)sectionId {

	NSString *k = [self valueForKey:@"mnemonic"];
	
	return [k substringWithRange:NSMakeRange( 0, 1)];
}

@end
