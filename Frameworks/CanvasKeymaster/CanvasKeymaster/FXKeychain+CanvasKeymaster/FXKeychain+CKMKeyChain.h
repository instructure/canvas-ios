//
// Created by Jason Larsen on 1/15/14.
// Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
@import FXKeychain;

@class CKIClient;

@interface FXKeychain (CKMKeychain)
+ (instancetype)sharedCanvasKeychain;

- (NSArray *)clients;
- (void)addClient:(CKIClient *)client;
- (void)removeClient:(CKIClient *)client;

- (void)clearKeychain;

@end
