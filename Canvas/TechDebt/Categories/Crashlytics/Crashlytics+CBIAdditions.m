//
//  Crashlytics+CBIAdditions
//  iCanvas
//
//  Created by Miles Wright on 2/27/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
    [Fabric with:@[[Crashlytics self]]];
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
