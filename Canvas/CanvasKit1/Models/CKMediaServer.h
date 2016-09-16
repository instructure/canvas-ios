//
//  CKMediaServer.h
//  CanvasKit
//
//  Created by Mark Suman on 9/15/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKMediaServer : NSObject

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, strong) NSURL *domain;
@property (nonatomic, strong) NSURL *resourceDomain;
@property (nonatomic, assign) uint64_t partnerId;

- (id)initWithInfo:(NSDictionary *)info;

// API URLs
- (NSURL *)apiURLAdd;
- (NSURL *)apiURLUpload;
- (NSURL *)apiURLAddFromUploadedFile;

@end
