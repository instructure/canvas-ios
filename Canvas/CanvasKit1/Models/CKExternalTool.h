//
//  CKExternalTool.h
//  CanvasKit
//
//  Created by derrick on 6/24/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKModelObject.h"

@interface CKExternalTool : CKModelObject
- (id)initWithName:(NSString *)name createSessionURL:(NSURL *)url;

@property (readonly) NSString *name;

@property (readonly) NSURL *createSessionURL;

@end
