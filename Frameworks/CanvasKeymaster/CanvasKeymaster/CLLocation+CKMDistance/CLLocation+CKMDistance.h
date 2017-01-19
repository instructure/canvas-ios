//
//  CLLocation+CKMDistance.h
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef double CKMLocationDistanceMiles;
typedef double CKMLocationDistanceKilometers;

@interface CLLocation (CKMDistance)

- (CKMLocationDistanceMiles)milesFromLocation:(const CLLocation *)location;
- (CKMLocationDistanceKilometers)kilometersFromLocation:(const CLLocation *)location;

@end
