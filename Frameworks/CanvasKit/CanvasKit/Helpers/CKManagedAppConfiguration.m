//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
