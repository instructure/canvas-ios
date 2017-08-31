//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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