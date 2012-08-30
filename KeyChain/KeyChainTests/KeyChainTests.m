//
//  KeyChainTests.m
//  KeyChainTests
//
//  Created by Bartolomeo Sorrentino on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyChainTests.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

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


-(void)testCryptor
{
    NSString * aPassword = @"password";
    NSString * dataToEncrypt = @"Data";
    
    NSData *data = [dataToEncrypt dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:aPassword
                                               error:&error];
    
    STAssertNotNil(encryptedData, @"encryptedData is null!");
    
    NSLog(@"\n==============\nEncrypted Data\n==============\n%@\n==============\n",
          encryptedData );
    /*
    This generates an NSData including a header, encryption salt, HMAC salt, IV, ciphertext, and HMAC. To decrypt this bundle:
    */
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                        withPassword:aPassword
                                               error:&error];
    
    STAssertNotNil(encryptedData, @"decryptedData is null!");
    
    NSString *decryptedDataAsString =
    [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];

    STAssertEqualObjects(dataToEncrypt, decryptedDataAsString, @"decrypted data doesn't match!");
    
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
    
    @autoreleasepool {

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        
        
        NSString *fileName = [NSString stringWithFormat:@"keylist-%@.plist", [dateFormat stringFromDate:[NSDate date]]  ];
        
        NSLog(@"filename [%@]", fileName);
    
    
    }

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
