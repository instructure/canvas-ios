//
// Copyright (C) 2016-present Instructure, Inc.
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

#import "FXKeychain+CKMKeychain.h"
@import CanvasKit;
@import ReactiveObjC;

static NSString * const CBIKeychainServiceID = @"com.instructure.shared-credentials";
static NSString * const CBIKeychainAccessGroup = @"8MKNFMCD9M.com.instructure.shared-credentials";

static const NSString *CBIKeychainClients = @"CBIKeychainClients";

@interface CKIClient (CBISerializable)
- (NSDictionary *)dictionaryValue;
+ (instancetype)clientFromDictionary:(NSDictionary *)dictionary;
@end

@implementation CKIClient (CBISerializable)

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[@"accessToken"] = self.accessToken;
    dictionary[@"baseURL"] = self.baseURL.absoluteString;
    dictionary[@"currentUser"] = [self.currentUser JSONDictionary];
    
    if (self.branding) {
        dictionary[@"branding"] = [self.branding JSONDictionary];
    }
    
    if (self.actAsUserID) {
        dictionary[@"actAsUserID"] = self.actAsUserID;
    }
    return dictionary;
}

+ (instancetype)clientFromDictionary:(NSDictionary *)dictionary
{
    NSString *accessToken = dictionary[@"accessToken"];
    NSString *baseURLString = dictionary[@"baseURL"];
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSDictionary *userDictionary = dictionary[@"currentUser"];
    NSDictionary *brandingDictionary = dictionary[@"branding"];
    NSString *actAsUserID = dictionary[@"actAsUserID"];
    CKIUser *user = [CKIUser modelFromJSONDictionary:userDictionary];
    
    CKIClient *client = [[CKIClient alloc] initWithBaseURL:baseURL];
    [client setValue:accessToken forKey:@"accessToken"];
    [client setValue:user forKey:@"currentUser"];
    client.actAsUserID = actAsUserID;

    if (brandingDictionary) {
        CKIBrand *branding = [CKIBrand modelFromJSONDictionary:brandingDictionary];
        [client setValue:branding forKey:@"branding"];
    }
    
    return client;
}

@end

@implementation FXKeychain (CBIKeychain)

+ (instancetype)sharedKeychain
{
    NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    if ([bundleID isEqualToString:@"com.instructure.ios.teacher"]) {
        return [FXKeychain defaultKeychain];
    }
    
    return [[FXKeychain alloc] initWithService:CBIKeychainServiceID accessGroup:CBIKeychainAccessGroup accessibility:FXKeychainAccessibleAfterFirstUnlock];
}

- (NSArray *)clients
{
    NSArray *clientDictionaries = [self clientDictionariesFromKeychain];
    NSArray *clients = [[clientDictionaries.rac_sequence map:^id(NSDictionary *dictionary) {
        return [CKIClient clientFromDictionary:dictionary];
    }] array];
    
    
    NSArray *validated = [clients filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CKIClient *client, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (!client.accessToken) return NO;
        if (!client.baseURL) return NO;
        if (!client.currentUser.id) return NO;
        
        return YES;
    }]];
    
    if (validated.count != clients.count) {
        [self clearKeychain];
        return @[];
    }
    
    return clients;
}

- (NSArray *)clientDictionariesFromKeychain
{
    __block NSMutableArray *clients = [self[CBIKeychainClients] mutableCopy] ?: [NSMutableArray new];
    
    if (![clients isKindOfClass:[NSArray class]]) {
        [self clearKeychain];
        return @[];
    }

    return clients;
}

- (void)addClient:(CKIClient *)client
{
    if (client.accessToken == nil) {
        return;
    }
    
    // We will always add the most recent client to the beginning of the array, thus the most recently used user will always be at index 0.
    // If an object with this user.id exists we will remove it from the array and insert it at the beginning.
    NSMutableArray *clients = [[self clientDictionariesFromKeychain] mutableCopy];
    NSUInteger existingClientIndex = [clients indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *user = obj[@"currentUser"];
        return [[NSString stringWithFormat:@"%@", user[@"id"]] isEqualToString:client.currentUser.id] && [obj[@"baseURL"] isEqualToString:client.baseURL.description];
    }];
    
    if (existingClientIndex == NSNotFound) {
        [clients insertObject:[client dictionaryValue] atIndex:0];
    } else {
        [clients removeObjectAtIndex:existingClientIndex];
        [clients insertObject:[client dictionaryValue] atIndex:0];
    }
    
    self[CBIKeychainClients] = clients;
}

- (void)removeClient:(CKIClient *)client
{
    NSArray *clients = [self clientDictionariesFromKeychain];
    NSArray *updatedClients = [[clients.rac_sequence filter:^BOOL(NSDictionary *clientDict) {
        return clientDict[@"accessToken"] != nil && ![clientDict[@"accessToken"] isEqualToString:client.accessToken];
    }] array];
    self[CBIKeychainClients] = updatedClients;
}

- (void)clearKeychain
{
    [self removeObjectForKey:CBIKeychainClients];
}

@end
