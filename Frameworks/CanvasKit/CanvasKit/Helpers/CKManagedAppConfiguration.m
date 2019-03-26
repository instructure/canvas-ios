//
// Copyright (C) 2019-present Instructure, Inc.
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

#import "CKManagedAppConfiguration.h"

static NSString * const kConfigurationKey = @"com.apple.configuration.managed";
static NSString * const kConfigurationEnableDemoKey = @"enableDemo";
static NSString * const kConfigurationUsernameKey = @"username";
static NSString * const kConfigurationPasswordKey = @"password";

static NSString * const kDemoDomain = @"pcraighill.instructure.com";

@implementation CKManagedAppConfiguration

- (void)beginObserving
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self readDefaultValues];
                                                  }];
    [self readDefaultValues];
}

- (void)readDefaultValues
{
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
    self.demoEnabled = defaults[kConfigurationEnableDemoKey];
    self.username = defaults[kConfigurationUsernameKey];
    self.password = defaults[kConfigurationPasswordKey];

    // Apple does not specify the domain.
    // This should match the domain specified in the App Store Connect demo area.
    // Right now we are using pcraighill for all of the apps.
    self.domain = @"pcraighill.instructure.com";

    [self.delegate managedAppConfigurationDidChange:self];
}

@end
