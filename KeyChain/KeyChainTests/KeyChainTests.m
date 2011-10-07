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
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
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
