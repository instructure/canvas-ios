//
//  CLLocation+CKMDistance.m
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CLLocation+CKMDistance.h"

static double const metersPerMile = 1609.34;
static double const metersPerKilometer = 1000;

@implementation CLLocation (CKMDistance)

- (CKMLocationDistanceMiles)milesFromLocation:(const CLLocation *)location {
    CLLocationDistance distance = [self distanceFromLocation:location];
    return distance/metersPerMile;
}
- (CKMLocationDistanceKilometers)kilometersFromLocation:(const CLLocation *)location {
    CLLocationDistance distance = [self distanceFromLocation:location];
    return distance/metersPerKilometer;
}

@end
