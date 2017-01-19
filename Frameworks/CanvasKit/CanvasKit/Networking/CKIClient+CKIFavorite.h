//
//  CKIClient+CKIFavorite.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKICourse;
@class RACSignal;

@interface CKIClient (CKIFavorite)

- (RACSignal *)fetchFavoriteCourses;

- (RACSignal *)addCourseToFavorites:(CKICourse *)course;

- (RACSignal *)removeCourseFromFavorites:(CKICourse *)course;

@end
