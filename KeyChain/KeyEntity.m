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


#pragma mark -
#pragma mark Grouping section
#pragma mark -

//
- (void)groupByPrefix:(NSString*)prefix {
    
    if( prefix == nil ) return;

    self.groupPrefix = prefix;
    self.group = [NSNumber numberWithBool:YES];
    
}

//
- (void)detachFromGroup {

    self.groupPrefix = nil;
    self.group = [NSNumber numberWithBool:NO];
    
}


/*
//
+ (void)groupByAppendingPrefix:(KeyEntity *)key prefix:(NSString*)prefix;
{
    
    if (prefix==nil || key==nil) {
        return;
    }
    
    key.mnemonic = [prefix stringByAppendingString:key.mnemonic];
    key.group = [NSNumber numberWithBool:YES];
}

//
+ (void)groupByReplacingName:(KeyEntity *)key mnemonic:(NSString*)name {
    if (name==nil || key==nil) {
        return;
    }
    
    key.mnemonic = name;
    key.group = [NSNumber numberWithBool:YES];
    
}

//
+ (void)groupByReplacingPrefix:(KeyEntity *)key groupKey:(NSString*)groupKey prefix:(NSString*)prefix {
    
    NSString *newMnemonic = [key.mnemonic 
                             stringByReplacingOccurrencesOfString:groupKey 
                             withString:prefix 
                             options:NSCaseInsensitiveSearch 
                             range:NSMakeRange(0, [groupKey length])];
    key.mnemonic = newMnemonic;
    key.group = [NSNumber numberWithBool:YES];
    
}
*/

#pragma mark static implementation

static  NSString * _REGEXP = @"(\\w+[-@/])(\\w+)";


+ (BOOL)isSectionAware:(KeyEntity *)key {
    
    NSPredicate *predicate = 
        [NSPredicate predicateWithFormat:@"SELF.mnemonic MATCHES %@",  _REGEXP];
    
    BOOL result = [predicate evaluateWithObject:key];
    
    return result;
}

+ (NSRange)getSectionPrefix:(KeyEntity*)key checkIfIsSectionAware:(BOOL)check {
    
    //@autoreleasepool {
        
        NSError *error = nil;
    
        NSRange result = NSMakeRange(NSNotFound, 0);

        if( !check || [KeyEntity isSectionAware:key] ) {
            
            NSRegularExpression *pattern = [[NSRegularExpression alloc] 
                                             initWithPattern:_REGEXP 
                                             options:NSRegularExpressionCaseInsensitive 
                                             error:&error ] ;
            if (pattern!=nil) {
                NSTextCheckingResult *match = 
                    [pattern firstMatchInString:key.mnemonic 
                                    options:0 
                                      range:NSMakeRange(0, [key.mnemonic length])];
                
                
                
                result = [match rangeAtIndex:1];
                
            }
            
        }

        return result;
    //}
    
}

+ (NSString *)sectionNameFromPrefix:(NSString *)prefix trim:(BOOL)trim {

    if( prefix == nil ) return nil;
    
    if( trim ) {
        prefix = [prefix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if( [prefix length] == 0 ) {
        return nil;
    }

    NSString *result = [prefix substringToIndex:[prefix length] -1];
    
    return result;
}


+ (KeyEntity *)createSection:  (NSString *)groupKey 
                  groupPrefix:(NSString *)groupPrefix
                    inContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KeyInfo" inManagedObjectContext:context];

   // NSString *entityName = [[source entity] name];
    NSString *entityName = [entity name];
    
    //create new object in data store
    KeyEntity *cloned = [NSEntityDescription
                         insertNewObjectForEntityForName:entityName
                         inManagedObjectContext:context];

/*    
    //loop through all attributes and assign then to the clone
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:entityName
                                 inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        if ([attr compare:_MNEMONIC]==0 ) continue;
        if ([attr compare:_IS_NEW]==0 ) continue;
        
        [cloned setValue:[source valueForKey:attr] forKey:attr];
        
    }
*/   
    [cloned setValue:@"nil" forKey:@"password"];
    [cloned setValue:@"nil" forKey:@"username"];
    
    cloned.group = NO;
    cloned.mnemonic = groupKey;
    cloned.groupPrefix = groupPrefix;
    
    return cloned;     
}


#pragma mark -
#pragma mark implementation
#pragma mark -

- (BOOL)isSection {
    return self.groupPrefix != nil && (self.group == nil || [self.group boolValue] == NO);
}

- (BOOL)isGrouped {
    return (self.groupPrefix != nil && self.group != nil && [self.group boolValue] == YES);
}

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

    [self setPrimitiveValue:[NSNumber numberWithBool:NO] forKey:_IS_NEW];
	
}

- (void)didSave {
    
    
    [self setPrimitiveValue:[NSNumber numberWithBool:NO] forKey:_IS_NEW];
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

@end
