//
//  CKIClient+CKIService.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKIService;
@class RACSignal;

@interface CKIClient (CKIService)

- (RACSignal *)fetchService;

@end
