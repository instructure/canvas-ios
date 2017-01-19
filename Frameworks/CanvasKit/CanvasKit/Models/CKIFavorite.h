//
//  CKIFavorite.h
//  CanvasKit
//
//  Created by rroberts on 9/17/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"

@interface CKIFavorite : CKIModel

/**
 The ID of the object the Favorite refers to
 */
@property (nonatomic, strong) NSString *contextID;

/**
 The type of the object the Favorite refers to (currently, only "Course" is supported)
 */
@property (nonatomic, strong) NSString *contextType;

@end
