//
//  CKByteCountFormatter.h
//  CanvasKit
//
//  Created by BJ Homer on 7/18/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKByteCountFormatter : NSObject

- (NSString *)stringFromByteCount:(long long)byteCount;

@end
