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
    
    

#import "CKCanvasURLConnection.h"
#import "CKCanvasAPI.h"
#import "CKCanvasAPIResponse.h"
#import "TouchXML.h"

NSString *CKAbortAllConnectionsNotification = @"CKAbortAllConnectionsNotification";

NSString *CKCanvasURLConnectionProgressNotification = @"CKCanvasURLConnectionProgressNotification";
NSString *CKCanvasURLConnectionProgressPercentageKey = @"progressPercentage";
NSString *CKCanvasURLConnectionProgressCurrentBytesKey = @"currentBytes";
NSString *CKCanvasURLConnectionProgressExpectedBytesKey = @"expectedBytes";
NSString *CKCanvasURLConnectionConnectionKey = @"connection";


NSString *CKCanvasNetworkRequestStartedNotification = @"CKCanvasNetworkRequestStartedNotification";
NSString *CKCanvasNetworkRequestFinishedNotification = @"CKCanvasNetworkRequestFinishedNotification";
NSString *CKCanvasNetworkNotConnectedToInternetNotification = @"CKCanvasNetworkNotConnectedToInternetNotification";

NSString *CKCanvasErrorDomain = @"CKCanvasErrorDomain";

static NSOperationQueue *writingQueue = nil;
#define FILE_DOWNLOAD_WRITE_BLOCKSIZE 16 * 1024

@interface CKCanvasURLConnection () {
    NSURLRequest *originalRequest;
    
    id abortLoadingObserver;
}
- (void)finishWithError:(NSError *)error;
@end


@implementation CKCanvasURLConnection

@synthesize url, doneCB, expectedBytes, receivedBytes, progressObject, filehandle, shouldCache, data, previousWriteOp, requestsDone, response;
@synthesize shouldFollowRedirects;

- (id)initWithRequest:(NSURLRequest *)request progressObject:(id)anObject filehandle:(NSFileHandle *)aFileHandle shouldCache:(BOOL)cacheValue callback:(CKHTTPURLConnectionDoneCB)block
{
    // Silencing this because we'll most likely never update this class to use NSURLSession, it'll be removed before that
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    self = [super initWithRequest:request delegate:self];
    #pragma GCC diagnostic pop
    if (self) {
        originalRequest = request;
        
        self.url = [request URL];
        self.doneCB = block;
        self.progressObject = anObject;
        self.filehandle = aFileHandle;
        self.shouldCache = cacheValue;
        self.requestsDone = YES;
        self.shouldFollowRedirects = YES;
        
        self.expectedBytes = NO_SIZE;
        
        if (writingQueue == nil) {
            writingQueue = [[NSOperationQueue alloc] init];
            [writingQueue setMaxConcurrentOperationCount:1];
        }
        
        self.data = [NSMutableData data];
        
        if (![self.url isFileURL]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CKCanvasNetworkRequestStartedNotification object:self];
        }

        [self registerForNotifications];
    }
    
    return self;    
}

- (void)registerForNotifications {
    abortLoadingObserver = [[NSNotificationCenter defaultCenter] addObserverForName:CKAbortAllConnectionsNotification
                                                                             object:nil
                                                                              queue:nil
                                                                         usingBlock:
                            ^(NSNotification *note) {
                                if (self.ignoreAbortAllConnections) {
                                    return;
                                }
                                self.doneCB = nil;
                                [self unregisterForNotifications];
                                [self cancel];
                            }];
}

- (void)unregisterForNotifications {
    if (abortLoadingObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:abortLoadingObserver];
        abortLoadingObserver = nil;
    }
}

+ (void)abortAllConnections {
    [[NSNotificationCenter defaultCenter] postNotificationName:CKAbortAllConnectionsNotification object:nil];
}

+ (NSString *)CKUserAgentString
{
    NSString *userAgentString = [[NSUserDefaults standardUserDefaults] objectForKey:CKUserAgentKey];
    
    if (userAgentString != nil) {
        return userAgentString;
    }
    else {
        return [NSString stringWithFormat:@"CanvasKit/1.0"];
    }
}

- (id)responseJSON
{
    return [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingAllowFragments error:nil];
}

- (CXMLDocument *)responseXML
{
    return [[CXMLDocument alloc] initWithData:self.data options:0 error:nil];
}

- (void)cancel {

    self.requestsDone = YES;
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
    [self finishWithError:error];
    [super cancel];
}

#pragma mark -
#pragma mark Operation Queue Stuff

- (void)writeDataOp:(NSDictionary *)info
{
    [self.filehandle writeData:info[@"data"]];
    
    NSNumber *finished = info[@"finished"];
    if (finished && [finished boolValue]) {
        [self performSelectorOnMainThread:@selector(finishWithError:) withObject:nil waitUntilDone:NO];
    }
}


#pragma mark -
#pragma mark NSURLConnection Delegate

- (void)connection:(CKCanvasURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    NSAssert([aResponse isKindOfClass:[NSHTTPURLResponse class]], @"Received a response that wasn't an HTTP response");
    self.response = (NSHTTPURLResponse *)aResponse;
    
    if ([self.response expectedContentLength] >= 0) {
        self.expectedBytes = [self.response expectedContentLength];
    }
}

- (NSURLRequest *)connection:(CKCanvasURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if (self.shouldFollowRedirects == NO && redirectResponse) {
        return nil;
    }
    if ([[[request URL] host] rangeOfString:[self.url host]].location == NSNotFound) {
        // We need to strip out the Authorization headers for requests away from our original domain
        NSMutableURLRequest *newRequest = [request mutableCopy];
        [newRequest setValue:nil forHTTPHeaderField:@"Authorization"];
        return newRequest;
    }
    
    return request;
}

- (void)connection:(CKCanvasURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    if (self.progressObject) {
        float progress = 0.0;
        if (totalBytesExpectedToWrite > 0) {
            progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
        
            NSDictionary *info = @{CKCanvasURLConnectionProgressPercentageKey: @(progress),
                                  CKCanvasURLConnectionProgressCurrentBytesKey: @(totalBytesWritten),
                                  CKCanvasURLConnectionProgressExpectedBytesKey: @(totalBytesExpectedToWrite),
                                  CKCanvasURLConnectionConnectionKey: self};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CKCanvasURLConnectionProgressNotification
                                                                object:self.progressObject
                                                              userInfo:info];
        }
    }
    
}

- (void)connection:(CKCanvasURLConnection *)connection didReceiveData:(NSData *)newData
{
    self.receivedBytes += [newData length];
    [self.data appendData:newData];

    if (self.filehandle && [self.data length] > FILE_DOWNLOAD_WRITE_BLOCKSIZE) {
        NSDictionary *opInfo = @{@"data": [self.data copy]};
        
        NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(writeDataOp:) object:opInfo];
        if (self.previousWriteOp) {
            [op addDependency:previousWriteOp];
        }
        self.previousWriteOp = op;
        
        [writingQueue addOperation:op];
        
        [[connection data] setLength:0];
    }
    
    if (self.progressObject) {
        float progress = 0.0;
        if (self.expectedBytes > 0) {
            progress = (float)self.receivedBytes / self.expectedBytes;
        
            NSDictionary *info = @{CKCanvasURLConnectionProgressPercentageKey: @(progress),
                                  CKCanvasURLConnectionProgressCurrentBytesKey: @(self.receivedBytes),
                                  CKCanvasURLConnectionProgressExpectedBytesKey: @(self.expectedBytes),
                                  CKCanvasURLConnectionConnectionKey: self};
            [[NSNotificationCenter defaultCenter] postNotificationName:CKCanvasURLConnectionProgressNotification
                                                                object:self.progressObject
                                                              userInfo:info];
        }
    }
}

- (void)connectionDidFinishLoading:(CKCanvasURLConnection *)connection
{
    if (self.filehandle) {
        NSDictionary *opInfo = @{@"fh": self.filehandle,
                                @"data": [self.data copy],
                                @"finished": @YES};
        
        NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(writeDataOp:) object:opInfo];
        if (self.previousWriteOp) {
            [op addDependency:self.previousWriteOp];
        }
        [writingQueue addOperation:op];
        
        return;
    }
    if (self.shouldCache &&
        [self.data length] == self.receivedBytes &&
        ![self.url isFileURL] &&
        (response.statusCode >= 200 && response.statusCode <= 300))
    {
        NSCachedURLResponse *responseForCache = [[NSCachedURLResponse alloc] initWithResponse:self.response data:self.data userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
        [[NSURLCache sharedURLCache] storeCachedResponse:responseForCache forRequest:originalRequest];
    }
    
    [self finishWithError:nil];
}

- (void)connection:(CKCanvasURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"HTTP request failed: %@", error);
    [self finishWithError:error];
}

- (void)finishWithError:(NSError *)error
{
    if (![self.url isFileURL]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CKCanvasNetworkRequestFinishedNotification object:self];
    }
    
    if ([[error domain] isEqualToString:NSURLErrorDomain] && [error code] == NSURLErrorNotConnectedToInternet) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CKCanvasNetworkNotConnectedToInternetNotification object:self userInfo:@{NSUnderlyingErrorKey: error}];
    }
    
    id responseObject = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:NULL];
    
    if (!error && [self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self.response;
        if ([httpResponse statusCode] < 200 || [httpResponse statusCode] > 399) {
            NSString *description = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                description = responseObject[@"message"];
                if (!description) {
                    id errors = responseObject[@"errors"];
                    if ([error isKindOfClass:[NSString class]]) {
                        description = errors;
                    } else if ([error isKindOfClass:[NSDictionary class]]) {
                        description = errors[@"message"];
                    }
                }
            }
            NSDictionary *userInfo = nil;
            if (description) {
                userInfo = @{NSLocalizedDescriptionKey: description};
            }
            error = [NSError errorWithDomain:CKCanvasErrorDomain code:[httpResponse statusCode] userInfo:userInfo];
            [[NSURLCache sharedURLCache] removeCachedResponseForRequest:originalRequest];
            NSLog(@"%li error connecting to url: %@ (Message: %@)", (long)error.code, self.url, error.localizedDescription);
        }
    }
    
    CKCanvasAPIResponse *apiResponse = [[CKCanvasAPIResponse alloc] initWithResponse:self.response data:self.data];
    
    if (self.doneCB) {
        self.doneCB(error, apiResponse, self.requestsDone);
    }
    if (self.requestsDone) {
        [self unregisterForNotifications];
    }
}

- (NSDate *)freshnessDate
{
    if ([self.url isFileURL]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.url path] error:nil];
        return [fileAttributes fileModificationDate];
    }
    
    // TODO: something from the response header to return?
    return [NSDate date];
}

@end


@implementation CKCanvasURLMockConnection

- (id)initWithData:(NSData *)newData
{
    // Note that we're not gonna call super here... we don't want to actually start a connection. Is this evil?
    self.data = [newData mutableCopy];
    return self;
}

@end

