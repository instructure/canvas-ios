//
//  CKCanvasURLConnection.h
//  CanvasKit
//
//  Created by Zach Wily on 6/10/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *CKCanvasURLConnectionProgressNotification;
extern NSString *CKCanvasURLConnectionProgressPercentageKey;
extern NSString *CKCanvasURLConnectionProgressCurrentBytesKey;
extern NSString *CKCanvasURLConnectionProgressExpectedBytesKey;
extern NSString *CKCanvasURLConnectionConnectionKey;


extern NSString *CKCanvasNetworkRequestStartedNotification;
extern NSString *CKCanvasNetworkRequestFinishedNotification;
extern NSString *CKCanvasNetworkNotConnectedToInternetNotification;

extern NSString *CKCanvasErrorDomain;

typedef enum {
    CKCanvasErrorCodeUnknown,
    CKCanvasErrorCodeParsing,
    CKCanvasErrorCodeUnknownHostname,
    CKCanvasErrorCodeMobileVerifyGeneralNotAuthorized,
    CKCanvasErrorCodeMobileVerifyDomainNotAuthorized,
    CKCanvasErrorCodeMobileVerifyUserAgentUnknown,
    CKCanvasErrorCodeMediaServerDisabled,
    CKCanvasErrorCodeFileUploadFailure
} CKCanvasErrorCode;

@class CKCanvasURLConnection, CXMLDocument, CKCanvasAPIResponse;

typedef void (^CKHTTPURLConnectionDoneCB)(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue);

#define NO_SIZE -1

@interface CKCanvasURLConnection : NSURLConnection

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) CKHTTPURLConnectionDoneCB doneCB;
@property (nonatomic, assign) long long expectedBytes;
@property (nonatomic, assign) long long receivedBytes;
@property (nonatomic, strong) id progressObject; // if set, we'll send out notifications on this object every time data comes in
@property (nonatomic, strong) NSFileHandle *filehandle; // if set, we'll write the incoming data to this filehandle
@property (nonatomic, assign) BOOL shouldCache;
@property (nonatomic, assign) BOOL shouldFollowRedirects;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSOperation *previousWriteOp;
@property (nonatomic, assign) BOOL requestsDone;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (weak, nonatomic, readonly) NSDate *freshnessDate;

@property BOOL ignoreAbortAllConnections;

- (id)initWithRequest:(NSURLRequest *)request
       progressObject:(id)anObject
           filehandle:(NSFileHandle *)aFileHandle
          shouldCache:(BOOL)cacheValue
             callback:(CKHTTPURLConnectionDoneCB)block;

+ (NSString *)CKUserAgentString;
+ (void)abortAllConnections;

- (void)finishWithError:(NSError *)error;

@end



@interface CKCanvasURLMockConnection : CKCanvasURLConnection {
}

- (id)initWithData:(NSData *)newData;

@end