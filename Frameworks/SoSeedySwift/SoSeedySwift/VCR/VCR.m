//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "VCR.h"

static NSDictionary *requests = nil;
static VCR *_shared = nil;

@implementation VCR
{
    BOOL _record;
};

RCT_EXPORT_MODULE();

+(void) initialize
{
    if (!requests) {
        requests = [[NSMutableDictionary alloc] init];
    }
}

- (instancetype)init
{
    self = [super init];
    if (_shared == nil) {
        _shared = self;
    }
    _record = YES;
    return self;
}

+ (VCR *)shared
{
    return _shared;
}

- (NSURL *)testCaseToUrl:(NSString *)testCase
{
    NSString *fileName = [testCase stringByReplacingOccurrencesOfString:@"-" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"[" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"]" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    // this URL will need to be replaced when we decide where we will be uploading the cassette files
    NSString *urlString = [NSString stringWithFormat:@"http://localhost:9000/cassettes/%@.json", fileName];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (void)loadCassette:(NSString *)testCase completionHandler:(void (^)(NSError *error))completionHandler
{
    if (_record) {
        requests = [[NSMutableDictionary alloc] init];
        return completionHandler(nil);
    }
    NSData *jsonData = [[NSData alloc] initWithContentsOfURL:[self testCaseToUrl:testCase]];
    NSError *error;
    requests = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    completionHandler(error);
}

- (void)recordCassette:(NSString *)testCase completionHandler:(void (^)(NSError *error))completionHandler
{
    // This line is only here to prevent from actually uploading the cassette files
    // as we don't have anywhere to upload them yet
    return completionHandler(nil);
    
    if (!_record) {
        return completionHandler(nil);
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requests options:nil error:&error];
    
    if (error == nil) {
        [self uploadCassetteFile:testCase jsonData:jsonData completionHandler:completionHandler];
    } else {
        [completionHandler error];
    }
}

- (void)uploadCassetteFile:(NSString *)testCase jsonData:(NSData *)jsonData completionHandler:(void (^)(NSError *error))completionHandler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self testCaseToUrl:testCase]];
    
    [request setHTTPMethod:@"PUT"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:jsonData];
    
    [request setHTTPBody:body];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        completionHandler(error);
    }];
    [task resume];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSString *)stringFrom:(NSDictionary *)dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requests options:nil error:&error];
    if (error != nil) {
        return nil;
    }
    NSString *key = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return key;
}

- (void)recordResponse:(NSString *)value for:(NSString *)key
{
    if (!_record) {
        return;
    }
    NSLog(key);
    NSLog(value);
    [requests setValue:requests[key] ? requests[key] : [[NSMutableArray alloc] init] forKey:key];
    [requests[key] addObject:value];
}

RCT_REMAP_METHOD(recordRequest, recordRequest:(NSString *) requestConfig responseConfig:(NSString *)responseConfig resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (!_record) {
        return resolve(nil);
    }
    [requests setValue:(requests[requestConfig] ? requests[requestConfig] : [[NSMutableArray alloc] init]) forKey:requestConfig];
    [requests[requestConfig] addObject:responseConfig];
    resolve(nil);
    
}

- (NSString *)responseFor:(NSString *)key {
    if (_record) {
        return nil;
    }

    if (requests[key]) {
        NSString *response = [requests[key] firstObject];
        [requests[key] removeObjectAtIndex:0];
        return response;
    }
    return nil;
}

RCT_REMAP_METHOD(responseForRequest, responseForRequest:(NSString *) requestConfig resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (_record) {
        return resolve(nil);
    }
    if (requests[requestConfig]) {
        NSString *response = [requests[requestConfig] firstObject];
        resolve(response);
        [requests[requestConfig] removeObjectAtIndex:0];
    } else {
        resolve(nil);
    }
}

@end
