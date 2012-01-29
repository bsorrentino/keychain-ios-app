//
//  KeyEntity.m
//  KeyChain
//
//  Created by softphone on 10/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyEntity.h"


static NSString * _MNEMONIC = @"mnemonic";
static NSString * _IS_NEW = @"isNew";

@implementation KeyEntity

@synthesize sectionId;
@dynamic mnemonic;
@dynamic group, groupPrefix;


- (BOOL)isEqualForImport:(id)object {

    if( object!=nil ) {
        
        NSString *k1 = nil;
    
        if ( [object isKindOfClass:[KeyEntity class]] ) {
        
            k1 = ((KeyEntity *)object).mnemonic;
        
        }
        else if( [object isKindOfClass:[NSDictionary class]] ) {
            
            k1 = [object valueForKey:_MNEMONIC];
            
        }
        else if( [object isKindOfClass:[NSString class]] ) {
            
            k1 = object ;
            
        }
    
        NSString *k = self.mnemonic;
        
        return (k!=nil) ? [k isEqualToString:k1] : NO;

    }
    
    return NO;
    
}

- (void)awakeFromFetch {

    [self setPrimitiveValue:NO forKey:_IS_NEW];
	
}

- (void)didSave {
    
    [self setPrimitiveValue:NO forKey:_IS_NEW];
}

//- (NSString *)mnemonic { return [self valueForKey:@"mnemonic"]; }
//- (void)setMnemonic:(NSString*)value { [self setValue:value forKey:@"mnemonic"]; }


-(BOOL)isNew {
	
	BOOL value = [[self primitiveValueForKey:_IS_NEW] boolValue];
	NSLog( @"isNew [%d]", value );
	
	return value;
	

}

- (NSString *)sectionId {

	NSString *k = [self valueForKey:_MNEMONIC];
	
	return [k substringWithRange:NSMakeRange( 0, 1)];
}

#pragma mark - Serialization

- (NSDictionary *)toDictionary:(NSMutableDictionary*)target {
    
    if (target == nil ) {
        return target;
    }
    
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    
    for (NSString *key in attributes) {
        
        if ([key compare:_IS_NEW]==0 ) continue;
        
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
        
        if ([key compare:_IS_NEW]==0 ) continue;
        
        NSObject* value = [source valueForKey:key];
        
        if (value != nil) {
            [self setValue:value forKey:key];
        }
        
    }
}

+ (KeyEntity *)cloneAsSection:  (NSString *)groupKey 
                  groupPrefix:(NSString *)groupPrefix
                       source:(KeyEntity *)source 
                    inContext:(NSManagedObjectContext *)context {
    
    NSString *entityName = [[source entity] name];
    
    //create new object in data store
    KeyEntity *cloned = [NSEntityDescription
                               insertNewObjectForEntityForName:entityName
                               inManagedObjectContext:context];
    
    //loop through all attributes and assign then to the clone
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:entityName
                                 inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        if ([attr compare:_MNEMONIC]==0 ) continue;
        if ([attr compare:_IS_NEW]==0 ) continue;
    
        [cloned setValue:[source valueForKey:attr] forKey:attr];

    }
    
    cloned.mnemonic = groupKey;
    cloned.groupPrefix = groupPrefix;
    
    return cloned;    
}

@end
