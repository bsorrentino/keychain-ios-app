//
//  KeyChainTests.m
//  KeyChainTests
//
//  Created by Bartolomeo Sorrentino on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyChainTests.h"


@implementation KeyChainTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    
    //id appDelegate    = [[UIApplication sharedApplication] delegate];
    //STAssertNotNil(appDelegate, @"Cannot find the application delegate");
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDirectoryList {
    
    BOOL expandTilde = YES;
    NSSearchPathDirectory destination = NSDocumentDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(destination, NSUserDomainMask, expandTilde);
    
    NSString *documentDirectory = [paths objectAtIndex:0];

    NSError *error;
    
    //NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:&error];
    NSArray *onlyPLISTs = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.plist'"]];    
    
    //[dirContents release];
    
    NSLog(@"list of folder [%@]", documentDirectory );
    for( id f in onlyPLISTs ) {
        
        NSLog(@"file [%@]", f );
    }
}

- (void)testSet {
    
}

- (void)testFormatDate
{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    
    NSString *fileName = [NSString stringWithFormat:@"keylist-%@.plist", [dateFormat stringFromDate:[NSDate date]]  ];
    
    NSLog(@"filename [%@]", fileName);
    
    
    [pool drain];

}

- (void)testRegularExpression
{
    
    NSError *error = nil;
    
    NSRegularExpression *pattern = [[NSRegularExpression alloc] 
                                    initWithPattern:@"(\\w+)[-@/](\\w+)" 
                                    options:NSRegularExpressionCaseInsensitive 
                                    error:&error ];
    NSString *s = @"SOFTPHONE-LinkedIn";
    
    NSTextCheckingResult *match = [pattern firstMatchInString:s options:0 range:NSMakeRange(0, [s length])];

    STAssertNotNil(match, @"match is nil");
    
    NSRange r1 = [match rangeAtIndex:1];
    
    STAssertTrue(r1.length == 9, @"match #1 size doesn't match [%d]", r1.length);
    NSLog(@"r1.location [%d] r1.length [%d]", r1.location, r1.length);
    
    r1 = [match rangeAtIndex:2];
    
    STAssertTrue(r1.length == 8, @"match #2 size doesn't match [%d]", r1.length);
    NSLog(@"r1.location [%d] r1.length [%d]", r1.location, r1.length);
    
    
    [pattern release];
}


- (void)testPredicate {

    static  NSString * _REGEXP = @"(\\w+)[-@/](\\w+)";
 
    NSPredicate *predicate = 
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@",  _REGEXP];

    {
    NSString *key = @"A-B";
    
    BOOL result = [predicate evaluateWithObject:key];
    
    STAssertTrue(result, @"string [%@] doesn't match [%@]", key, _REGEXP);
    }

    {
        NSString *key = @"A";
        
        BOOL result = [predicate evaluateWithObject:key];
        
        STAssertFalse(result, @"string [%@] match [%@]", key, _REGEXP);
    }
    
}

@end
