//
//  AccountCredential.m
//  KeyChain
//
//  Created by softphone on 30/08/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "AccountCredential.h"
#import "SSKeychain.h"

@implementation AccountCredential
@synthesize password;
@synthesize version;
@synthesize bundleVersion;
@synthesize encryptionEnabled;

static AccountCredential *_sharedInstance;

+ (AccountCredential *)sharedCredential
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AccountCredential alloc] init];
        //[_sharedInstance setEncryptionEnabled:YES];
    });
    
    return _sharedInstance;
}

-(NSString *)getBundleVersion
{
    NSString *_bundleVersion =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    return _bundleVersion;
    
}

// check if currentVersion is different to bundleVersion
// return YES if are differents
-(BOOL)checkAndUpdateCurrentVersion
{
    if( self.version == nil || [self.version compare:self.bundleVersion options:NSCaseInsensitiveSearch] )
    {

        self.version = self.bundleVersion;
        
        return YES;
    }
        
    return NO;
}

-(NSString*) password {
    
    // Issue 16

    NSString *_passwd = [SSKeychain passwordForService:@"it.softphone.keychain" account:@"softphone" error:nil];
    
    if( _passwd == nil ) {
    
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *result = [prefs objectForKey:@"pwd"];
    
        if( result != nil && [SSKeychain setPassword:result forService:@"it.softphone.keychain" account:@"softphone"] )
        {
                
            _passwd = result;
                
            [prefs removeObjectForKey:@"pwd"];
            [prefs synchronize];
        }
    
    }
    
	return _passwd;
}

-(void) setPassword:(NSString *)value {
    
    // Issue 16
    BOOL result = [SSKeychain setPassword:value forService:@"it.softphone.keychain" account:@"softphone"];

    NSAssert( result , @"set password in system keichain failed!");
   
    if( !result )  {
        
        NSLog(@"set password in system keichain failed!");
    
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:value forKey:@"pwd"];
        [prefs synchronize];
    }
}

-(NSString*) version {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *result = [prefs objectForKey:@"ver"];
	return result;
}

-(void) setVersion:(NSString *)value {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:value forKey:@"ver"];
	[prefs synchronize];
}

-(BOOL) encryptionEnabled
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	BOOL result = [prefs boolForKey:@"encryption"];
	return result;
}

-(void) setEncryptionEnabled:(BOOL)value
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:value forKey:@"encryption"];
	[prefs synchronize];
}

@end
