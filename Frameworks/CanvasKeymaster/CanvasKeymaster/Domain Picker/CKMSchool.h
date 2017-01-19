//
//  CKMSchool.h
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CKMSchool : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSMutableArray *locations;

- (CLLocation *)closestLocationToLocation:(CLLocation *)location;

+ (NSArray *)developmentSchoolsAtLocation:(CLLocation *)location;
+ (CKMSchool *)canvasNetSchool;
+ (CKMSchool *)cantFindSchool;

@end
