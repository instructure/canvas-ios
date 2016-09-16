//
//  CKPaginationInfo.h
//  CanvasKit
//
//  Created by BJ Homer on 9/19/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKPaginationInfo : NSObject

@property (readonly) NSURL *firstPage;
@property (readonly) NSURL *previousPage;
@property (readonly) NSURL *nextPage;
@property (readonly) NSURL *lastPage;

@property (readonly) NSURL *currentPage;

- (id)initWithResponse:(NSHTTPURLResponse *)httpResponse;

@end
