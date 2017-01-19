//
//  CKIMediaServer.h
//  CanvasKit
//
//  Created by Rick Roberts on 11/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKIMediaServer : NSObject
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, strong) NSURL *domain;
@property (nonatomic, strong) NSURL *resourceDomain;
@property (nonatomic, strong) NSString *partnerId;

- (id)initWithInfo:(NSDictionary *)info;

// API URLs
- (NSURL *)apiURLAdd;
- (NSURL *)apiURLUpload;
- (NSURL *)apiURLAddFromUploadedFile;
@end
