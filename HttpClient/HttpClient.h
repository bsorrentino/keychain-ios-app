//
//  Wrapper.h
//  WrapperTest
//
//  Created by Adrian on 10/18/08.
//  Copyright 2008 Adrian Kosmaczewski. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import "HttpClientDelegate.h"

@class UIAlertView;

@interface HttpClient : NSObject 
{
@private
    NSMutableData *receivedData;
    NSString *mimeType;
    NSURLConnection *conn;
    BOOL asynchronous;
    NSObject<HttpClientDelegate> *delegate;
    NSString *username;
    NSString *password;
	NSInteger tag;
    
    UIAlertView *waitView_;
    
}

@property (nonatomic, readonly) NSData *receivedData;
@property (nonatomic) BOOL asynchronous;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) NSObject<HttpClientDelegate> *delegate; // Do not retain delegates!
@property (nonatomic, readonly) NSInteger tag;                // default is 0

- (id) initWithTag:(NSInteger) tag;
- (void)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSDictionary *)parameters;
- (void)sendMaskedRequestTo:(NSString *)message url:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSDictionary *)parameters;
- (void)uploadData:(NSData *)data toURL:(NSURL *)url;
- (void)cancelConnection;
- (NSDictionary *)responseAsPropertyList;
- (NSString *)responseAsText;

@end

