//
//  TableViewDataEntryTests.m
//  TableViewDataEntryTests
//
//  Created by softphone on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableViewDataEntryTests.h"
#import "FormData.h"

@implementation TableViewDataEntryTests


- (void)setUp
{
    [super setUp];
    
    d = [[FormData alloc] init];
    
    STAssertNotNil(d, @"FormData is nil");
    
    
    [d.model setValue:@"Bartolomeo" forKey:@"name"];
    [d.model setValue:@"Sorrentino" forKey:@"sname"];
}

- (void)tearDown
{
    [d release];
    
    [super tearDown];
}

- (void)testNSPropertyListSerialization {
    
    NSMutableArray *root = [[NSMutableArray alloc] init];
    
    [root addObject:d.model];
    
    NSString *errorDescription;
    
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:root format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDescription ];
    
    STAssertNotNil(data, @"dataFromPropertyList returned nil. error [%@[", errorDescription);
 
    NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"%@", dataAsString);
    
    [dataAsString release];
}


- (void)testArchiver
{
    //STFail(@"Unit tests are not implemented yet in TableViewDataEntryTests");
    
    
    NSMutableData *data = [NSMutableData data];

    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    
    [archiver encodeObject:d forKey:@"data"];
    [archiver finishEncoding];
    
    [archiver release];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc ] initForReadingWithData:data];
    
    FormData *d1 = [unarchiver decodeObjectForKey:@"data"];
    
    STAssertNotNil(d1, @"Unarchived FormData is nil");
    
    
    STAssertEqualObjects( [d1.model valueForKey:@"name"], @"Bartolomeo", @"name is different" );
    STAssertEqualObjects( [d1.model valueForKey:@"sname"], @"Sorrentino", @"sname is different" );
    
    NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"%@", dataAsString);
    
    [dataAsString release];
    
}

@end
