//
//  FXKeychain.h
//
//  Version 1.5.3
//
//  Created by Nick Lockwood on 29/12/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/FXKeychain
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import <Foundation/Foundation.h>
#import <Security/Security.h>


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


#import <TargetConditionals.h>
#ifndef FXKEYCHAIN_USE_NSCODING
#if TARGET_OS_IPHONE
#define FXKEYCHAIN_USE_NSCODING 1
#else
#define FXKEYCHAIN_USE_NSCODING 0
#endif
#endif


typedef NS_ENUM(NSInteger, FXKeychainAccess)
{
    FXKeychainAccessibleWhenUnlocked = 0,
    FXKeychainAccessibleAfterFirstUnlock,
    FXKeychainAccessibleAlways,
    FXKeychainAccessibleWhenUnlockedThisDeviceOnly,
    FXKeychainAccessibleAfterFirstUnlockThisDeviceOnly,
    FXKeychainAccessibleAlwaysThisDeviceOnly
};


@interface FXKeychain : NSObject

+ (nonnull instancetype)defaultKeychain;

@property (nonatomic, readonly, nullable) NSString *service;
@property (nonatomic, readonly, nullable) NSString *accessGroup;
@property (nonatomic, assign) FXKeychainAccess accessibility;

- (nonnull id)initWithService:(nullable NSString *)service
                  accessGroup:(nullable NSString *)accessGroup
                accessibility:(FXKeychainAccess)accessibility;

- (nonnull id)initWithService:(nullable NSString *)service
                  accessGroup:(nullable NSString *)accessGroup;

- (BOOL)setObject:(nullable id)object forKey:(nonnull id)key;
- (BOOL)setObject:(nullable id)object forKeyedSubscript:(nonnull id)key;
- (BOOL)removeObjectForKey:(nonnull id)key;
- (nullable id)objectForKey:(nonnull id)key;
- (nullable id)objectForKeyedSubscript:(nonnull id)key;

@end


#pragma GCC diagnostic pop

