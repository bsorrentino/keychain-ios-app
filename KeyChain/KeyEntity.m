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
@dynamic mnemonic;

- (void)awakeFromFetch {

    [self setPrimitiveValue:NO forKey:@"isNew"];
	
}

- (void)didSave {

    [self setPrimitiveValue:NO forKey:@"isNew"];
}

//- (NSString *)mnemonic { return [self valueForKey:@"mnemonic"]; }
//- (void)setMnemonic:(NSString*)value { [self setValue:value forKey:@"mnemonic"]; }


-(BOOL)isNew {
	
	BOOL value = [[self primitiveValueForKey:@"isNew"] boolValue];
	NSLog( @"isNew [%d]", value );
	
	return value;
	

}

- (NSString *)sectionId {

	NSString *k = [self valueForKey:@"mnemonic"];
	
	return [k substringWithRange:NSMakeRange( 0, 1)];
}

#pragma mark - Serialization

- (NSDictionary *)toDictionary:(NSMutableDictionary*)target {
    
    if (target == nil ) {
        return target;
    }
    
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    
    for (NSString *key in attributes) {
        
        if ([key compare:@"isNew"]==0 ) continue;
        
        NSObject* value = [self valueForKey:key];
        
        if (value != nil) {
            [target setObject:value forKey:key];
        }
        
    }
    return target;
}

- (void)fromDictionary:(NSDictionary *)source {

    if (source == nil ) {
        return;
    }
    
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    
    for (NSString *key in attributes) {
        
        if ([key compare:@"isNew"]==0 ) continue;
        
        NSObject* value = [source valueForKey:key];
        
        if (value != nil) {
            [self setValue:value forKey:key];
        }
        
    }
}

@end
