//
//  NSFileManager+CKAdditions.h
//  CanvasKit
//
//  Created by Mark Suman on 4/18/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (CKAdditions)

- (NSURL *)uniqueFileURLWithURL:(NSURL *)url;

@end
