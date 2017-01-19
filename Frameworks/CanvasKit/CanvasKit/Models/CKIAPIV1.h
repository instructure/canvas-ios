//
//  CKIAPIV1.h
//  CanvasKit
//
//  Created by derrick on 9/17/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKIContext.h"

@interface CKIAPIV1 : NSObject <CKIContext>
+ (instancetype)context;
@end
