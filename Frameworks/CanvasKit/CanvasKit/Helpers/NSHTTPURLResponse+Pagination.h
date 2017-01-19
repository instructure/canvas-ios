//
//  NSHTTPURLResponse+Pagination.h
//  CanvasKit
//
//  Created by Jason Larsen on 9/19/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (Pagination)
@property (nonatomic, readonly) NSURL *currentPage;
@property (nonatomic, readonly) NSURL *nextPage;
@property (nonatomic, readonly) NSURL *previousPage;
@property (nonatomic, readonly) NSURL *firstPage;
@property (nonatomic, readonly) NSURL *lastPage;
@end
