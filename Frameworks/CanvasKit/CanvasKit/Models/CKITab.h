//
//  CKITab.h
//  CanvasKit
//
//  Created by rroberts on 9/17/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"

@class CKICourse;

@interface CKITab : CKIModel

@property (nonatomic) NSURL *htmlURL;

@property (nonatomic) NSString *label;

@property (nonatomic) NSString *type;

@property (nonatomic) NSURL *url;

@end
