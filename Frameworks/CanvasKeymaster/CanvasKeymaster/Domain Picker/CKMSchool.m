//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    canvasNetSchool.name = NSLocalizedStringFromTableInBundle(@"Can't find your school?", nil, [NSBundle bundleForClass:[self class]], @"Help label when user can't find their school.");
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
