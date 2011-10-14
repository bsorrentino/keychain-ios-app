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
    
    [dirContents release];
    
    NSLog(@"list of folder [%@]", documentDirectory );
    for( id f in onlyPLISTs ) {
        
        NSLog(@"file [%@]", f );
    }
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

@end
