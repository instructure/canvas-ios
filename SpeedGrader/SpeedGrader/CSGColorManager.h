//
//  CSGColorManager.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 11/3/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSGColorManager : NSObject

- (void)fetchColorDataForUserWithSuccess:(void (^)())success failure:(void (^)())failure;

- (void)saveColorDataForUserWithSuccess:(void (^)())success failure:(void (^)())failure;

@end

