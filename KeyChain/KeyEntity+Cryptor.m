//
//  KeyEntity+Crypto.m
//  KeyChain
//
//  Created by softphone on 25/09/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "KeyEntity+Cryptor.h"
#import "AccountCredential.h"
#import "RNCryptor/RNEncryptor.h"
#import "RNCryptor/RNDecryptor.h"

const NSStringEncoding _ENCODING = NSUTF8StringEncoding;

@implementation KeyEntity (Cryptor)

- (NSData*)encryptValue:(NSString*)data useKey:(NSString *)keyOrNil
{
    if (nil == data) return nil;
    
    NSData *dataEncoded = [data dataUsingEncoding:_ENCODING];
    
    // If there's no key (e.g. during a data migration), don't try to transform the data
    if (nil == keyOrNil) return dataEncoded;
    
    NSError *error = nil;
    
    NSData *encryptedData =
    [RNEncryptor encryptData:dataEncoded
                withSettings:kRNCryptorAES256Settings
                    password:keyOrNil
                       error:&error];
    if( error != nil ) {
        NSLog(@"error encripting data\n[%@]", [error description] );
        return dataEncoded;
    }
    if( encryptedData == nil ) {
        NSLog(@"error encripting data\nresult is nil" );
        return dataEncoded;
    }
    
    return encryptedData;
}

- (NSData*)decryptValue:(NSData*)encryptedData useKey:(NSString *)keyOrNil
{
    if (nil == encryptedData) return nil;
    
    // If there's no key (e.g. during a data migration), don't try to transform the data
    if (nil == keyOrNil) return encryptedData;
    
    
    NSError *error = nil;
    
#ifdef _ENCRYPT_TEST
    
    NSData *decryptedData = encryptedData;
    
#else
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                        withPassword:keyOrNil
                                               error:&error];
    
#endif
    if( error != nil ) {
        NSLog(@"error decripting data\n[%@]", [error description] );
        return encryptedData;
    }
    if( decryptedData == nil ) {
        NSLog(@"error decripting data\nresult is nil" );
        return encryptedData;
    }
    return decryptedData;
    
}

-(NSString*)getPasswordDecrypted
{
    NSString * result = [self reverseTransformedValue:self.password];
    return result;
}

-(void)setPasswordToEncrypt:(NSString*)value
{
    self.password = [self transformedValue:value];
}

-(BOOL)isPasswordDecrypted
{
    
    NSData *dataEncoded = (NSData*)self.password;
    
    return [[self class] isDataDecrypted:dataEncoded];
    
}

+(BOOL)isDataDecrypted:(NSData *)data
{
    NSAssert( data!=nil, @"data is nil!" );
    if( data == nil ) return NO;
    NSAssert( [data length] > 2, @"data length is invalid!" );
    if( [data length] <= 2 ) return NO;
    
    Byte * bytes = (Byte *)[data bytes];
    
    return ( bytes[0]==10 && bytes[1]==10 );
    
}


#pragma mark - methods for bulk crypt and/or encrypt

-(void)encryptPassword
{
    NSLog(@"encrypting password for [%@] ....", self.mnemonic);
    
    //
    // TODO check reason that isPasswordDecrypted doesn't work
    //
    //if ([self isPasswordDecrypted]) {
    //    NSLog(@"password for [%@] is already encrypted", self.mnemonic);
    //    return;
    //}
    
    NSData *dataEncoded = self.password;

    NSMutableData * mutable = [NSMutableData dataWithCapacity:[dataEncoded length] + 2];
    
    Byte prefix[2] = { 10, 10 };
    
    [mutable appendBytes:prefix length:2];
    [mutable appendData:dataEncoded];
    
    NSString *value = [[NSString alloc] initWithData:mutable
                          encoding:_ENCODING];
    
    //NSAssert(value!=nil, @"NSData to NSString failed!");
    
    if( value != nil ) {
        
        self.password =
            [self encryptValue:value
                        useKey:[AccountCredential sharedCredential].password];
    }
    else {
        NSLog(@"ERROR encrypting password for [%@]", self.mnemonic);
        
    }
    
}

-(void)decryptPassword
{
    NSLog(@"decrypting password for [%@] ....", self.mnemonic);
    
    //
    // TODO check reason that isPasswordDecrypted doesn't work
    //
    //if (![self isPasswordDecrypted]) {
    //    NSLog(@"password for [%@] is already encrypted", self.mnemonic);
    //    return;
    //}
    
    NSData *dataEncoded =
        [self decryptValue:self.password
                    useKey:[AccountCredential sharedCredential].password];
    
    //NSAssert([[self class ] isDataDecrypted:dataEncoded],
    //         @"ERROR decrypting password for [%@]", self.mnemonic);
    
    if( ![[self class ] isDataDecrypted:dataEncoded]) {
        NSLog(@"ERROR decrypting password for [%@]", self.mnemonic);
        return;
    }
    
    NSData * mutable = [dataEncoded subdataWithRange:NSMakeRange(2,[dataEncoded length]-2)];
    
    self.password = mutable;
    
}

#pragma mark - NSValueTransformer aware

+ (NSString*)dataToString:(NSData *)data
{
    if( data == nil ) return nil;
    return [[NSString alloc] initWithData:data
                                 encoding:_ENCODING];
}


//Returns the key used for encrypting / decrypting values during transformation.
- (NSString*)key
{
    BOOL _encryptionEnabled = [AccountCredential sharedCredential].encryptionEnabled;
    
    // Your version of this class might get this key from the app delegate or elsewhere.
    return ( _encryptionEnabled ) ?
    [AccountCredential sharedCredential].password :
    nil;
}


- (id)transformedValue:(NSString*)data
{
    return [self encryptValue:data useKey:[self key]];
}

- (id)reverseTransformedValue:(NSData*)encryptedData
{
    NSData * result = [self decryptValue:encryptedData useKey:[self key]];
    return [[self class] dataToString:result];
}



@end
