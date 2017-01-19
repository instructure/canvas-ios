//
//  CKIClient+CKITab.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKITab;
@class CKICourse;
@class RACSignal;

@interface CKIClient (CKITab)

- (RACSignal *)fetchTabsForContext:(id<CKIContext>)context;

@end
