//
//  CKMLocationManager.h
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class RACSignal;

extern NSString *const CKMLocationManagerLocationDidUpdateNotification;
extern NSString *const CKMLocationManagerLocationDidFailNotification;

extern NSString *const CKMLocationManagerUserInfoLocationKey;
extern NSString *const CKMLocationManagerUserInfoTimestampKey;
extern NSString *const CKMLocationManagerUserInfoErrorKey;

@interface CKMLocationManager : NSObject

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

+ (instancetype)sharedInstance;
- (RACSignal *)locationSignal;
- (void)startUpdatingLocation;

@end
