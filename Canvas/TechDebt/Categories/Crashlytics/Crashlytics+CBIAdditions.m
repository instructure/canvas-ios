//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

#import "Crashlytics+CBIAdditions.h"
#import <Fabric/Fabric.h>

#define kCrashlyticsBaseURLKey @"DOMAIN"
#define kCrashlyticsMasqueradeAsUserID @"MASQUERADE_AS_USER_ID"
@import CanvasKit;
@import CanvasKeymaster;

@implementation Crashlytics (CBIAdditions)

+ (void)prepare
{
    NSDictionary *fabric = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Fabric"];
    if (fabric) {
        [Fabric with:@[[Crashlytics self]]];
    }
    else {
        NSLog(@"WARNING: Crashlytics was not properly initialized.");
    }
}

+ (void)setDebugInformation
{
    CKIClient *client = [CKIClient currentClient];

    // We cannot save user data from Simon Fraser University in Canada.
    // Make sure that we are not adding user data to crash reports
    NSString *baseURLString = [client.baseURL absoluteString];
    if (![baseURLString hasSuffix:@"sfu.ca"]) {
        CKIUser *user = [[CKIClient currentClient] currentUser];
        [[Crashlytics sharedInstance] setObjectValue:[CKIClient currentClient].actAsUserID forKey:kCrashlyticsMasqueradeAsUserID];
        [[Crashlytics sharedInstance] setObjectValue:baseURLString forKey:kCrashlyticsBaseURLKey];
        [[Crashlytics sharedInstance] setUserIdentifier:user.id];
    }
}


@end
