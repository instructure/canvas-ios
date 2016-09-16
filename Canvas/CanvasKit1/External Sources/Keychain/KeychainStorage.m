//
//  KeychainStorage.m
//  iCanvas
//
//  Created by Mark Suman on 4/9/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "KeychainStorage.h"
#import <Security/Security.h>

@implementation KeychainStorage {
    NSString *serviceName;
}

- (id)initWithServiceName:(NSString *)name
{
    self = [super init];
    if (self) {
        serviceName = name;
    }
    
    return self;
}

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];  
    
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = serviceName;
    
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    // Add search return types
    searchDictionary[(__bridge id)kSecReturnData] = (id)kCFBooleanTrue;
    
    CFDataRef attributes = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef *)&attributes);
    
    if (status != 0) {
        //failed - error handle
    }
    NSData *result = (__bridge NSData *)attributes;
    return result;
}

- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    updateDictionary[(__bridge id)kSecValueData] = passwordData;
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (void)deleteKeychainValue:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    dictionary[(__bridge id)kSecValueData] = passwordData;
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

-(NSString*)valueForIdentifier:(NSString *)identifier{
    NSData *passwordData = [self searchKeychainCopyMatching:identifier];
    if (passwordData) {
        NSString *password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        return password;
    } else {
        return nil;
    }
}

@end