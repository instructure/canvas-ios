//
//  KeychainStorage.h
//  iCanvas
//
//  Created by Mark Suman on 4/9/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainStorage : NSObject

- (id)initWithServiceName:(NSString *)name;

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier;

- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;

- (void)deleteKeychainValue:(NSString *)identifier;

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;

-(NSString*)valueForIdentifier:(NSString *)identifier;

@end