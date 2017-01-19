//
//  CKIClient+CKIPage.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKICourse;
@class CKIPage;
@class RACSignal;

@interface CKIClient (CKIPage)

- (RACSignal *)fetchPagesForContext:(id<CKIContext>)context;

- (RACSignal *)fetchPage:(NSString *)pageID forContext:(id<CKIContext>)context;

- (RACSignal *)fetchFrontPageForContext:(id<CKIContext>)context;

@end
