//
//  CKUser.h
//  CanvasKit
//
//  Created by Mark Suman on 12/9/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@interface CKUser : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *loginId;
@property (nonatomic, strong) NSString *primaryEmail;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *sortableName;
@property (nonatomic, strong) NSString *sisLoginId;
@property (nonatomic, strong) NSString *sisUserId;
@property (nonatomic, strong) NSURL *avatarURL;

@property (strong) NSURL *calendarURL;
@property (nonatomic, strong) NSArray *collections;

@property BOOL loggedIn;

- (id)initWithInfo:(NSDictionary *)info;

- (void)updateWithInfo:(NSDictionary *)info;

@end
