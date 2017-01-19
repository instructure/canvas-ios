//
//  CKMSchool.m
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKMSchool.h"

@implementation CKMSchool

- (id)init {
    self = [super init];
    if (self) {
        _locations = [NSMutableArray array];
    }
    return self;
}

- (CLLocation *)closestLocationToLocation:(CLLocation *)location {
    // return nothing if we have no locations
    if(![self.locations count]) {
        return nil;
    }
    
    // loop through the locations to find the location closest to the location provided
    __block CLLocationDistance shortestDistance = NSNotFound;
    __block NSUInteger closestLocationIndex = NSNotFound;
    [self.locations enumerateObjectsUsingBlock:^(CLLocation *aLocation, NSUInteger idx, BOOL *stop) {
        CLLocationDistance distanceBetweenLocations = [aLocation distanceFromLocation:location];
        if (shortestDistance > distanceBetweenLocations) {
            shortestDistance = distanceBetweenLocations;
            closestLocationIndex = idx;
        }
    }];
    
    CLLocation *closestLocation = self.locations[closestLocationIndex];
    
    return closestLocation;
}

+ (CKMSchool *)canvasNetSchool {
    CKMSchool *canvasNetSchool = [CKMSchool new];
    canvasNetSchool.name = @"Canvas Network";
    canvasNetSchool.domain = @"learn.canvas.net";
    return canvasNetSchool;
}

+ (CKMSchool *)cantFindSchool {
    CKMSchool *canvasNetSchool = [CKMSchool new];
    canvasNetSchool.name = NSLocalizedString(@"Can't find your school?", @"Help label when user can't find their school.");
    return canvasNetSchool;
}

+ (NSArray *)developmentSchoolsAtLocation:(CLLocation *)location {
    NSArray *devDomains = @[@"mobileqa", @"mobileqat", @"ben-k", @"mobiledev", @"clare"];
    
    __block NSMutableArray *devSchools = [NSMutableArray array];
    [devDomains enumerateObjectsUsingBlock:^(NSString *domain, NSUInteger idx, BOOL *stop) {
        CKMSchool *canvasNetSchool = [CKMSchool new];
        canvasNetSchool.name = domain;
        canvasNetSchool.domain = domain;
        if (location) {
            [canvasNetSchool.locations addObject:location];
        }
        [devSchools addObject:canvasNetSchool];
    }];
    
    return devSchools;
}

@end
