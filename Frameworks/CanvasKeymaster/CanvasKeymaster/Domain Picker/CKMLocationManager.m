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

#import "CKMLocationManager.h"
@import ReactiveObjC;

@interface CKMLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) RACSubject *locationSubject;

@end

NSString *const CKMLocationManagerLocationDidUpdateNotification = @"CKMLocationManagerLocationDidUpdateNotification";
NSString *const CKMLocationManagerLocationDidFailNotification = @"CKMLocationManagerLocationDidFailNotification";

NSString *const CKMLocationManagerUserInfoLocationKey = @"CKMLocationManagerUserInfoLocationKey";
NSString *const CKMLocationManagerUserInfoTimestampKey = @"CKMLocationManagerUserInfoTimestampKey";
NSString *const CKMLocationManagerUserInfoErrorKey = @"CKMLocationManagerUserInfoTimestampKey";

@implementation CKMLocationManager

+ (instancetype)sharedInstance {
    static CKMLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

#pragma mark - Location Manager Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    
    [self.locationSubject sendNext:[locations lastObject]];
    
    NSDictionary *userInfo = @{CKMLocationManagerUserInfoLocationKey : locations,
                               CKMLocationManagerUserInfoTimestampKey : [NSDate date]};
    [[NSNotificationCenter defaultCenter] postNotificationName:CKMLocationManagerLocationDidUpdateNotification object:nil userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    [self.locationSubject sendError:error];
    
    NSDictionary *userInfo = @{CKMLocationManagerUserInfoErrorKey : error,
                               CKMLocationManagerUserInfoTimestampKey : [NSDate date]};
    [[NSNotificationCenter defaultCenter] postNotificationName:CKMLocationManagerLocationDidFailNotification object:nil userInfo:userInfo];
}

- (void)startUpdatingLocation {
    // Let's stop asking for user's location until we have school locations to actually justify it
//    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//        [self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
//    }
//
//    [self.locationManager startUpdatingLocation];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 30;
    }
    return _locationManager;
}

#pragma mark - RAC stuff
- (RACSignal *)locationSignal
{
    return self.locationSubject;
}

- (RACSubject *)locationSubject
{
    if (!_locationSubject) {
        _locationSubject = [RACSubject subject];
    }
    return _locationSubject;
}

@end
