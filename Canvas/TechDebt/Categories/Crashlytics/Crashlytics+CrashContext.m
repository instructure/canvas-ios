//
//  Crashlytics+CrashContext.m
//  iCanvas
//
//  Created by derrick on 3/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import <CanvasKit1/CanvasKit1.h>

#import "Crashlytics+CrashContext.h"
#import "CKAPICredentials.h"

NSString *const CrashContextHostname = @"HOSTNAME";
NSString *const CrashContextContextIdent = @"CONTEXT_IDENT";
NSString *const CrashContextContextType = @"CONTEXT_TYPE";
NSString *const CrashContextMessaging = @"MESSAGING";


@implementation Crashlytics (CrashContext)

+ (void)setCredentials:(CKAPICredentials *)creds
{
    [[Crashlytics sharedInstance] setUserIdentifier:[NSString stringWithFormat:@"%llu", creds.userIdent]];
    [[Crashlytics sharedInstance] setUserEmail:creds.userName];
    [[Crashlytics sharedInstance] setObjectValue:creds.hostname forKey:CrashContextHostname];
}

+ (void)setContext:(CKContextInfo *)context
{
    [[Crashlytics sharedInstance] setObjectValue:@(context.contextType) forKey:CrashContextContextType];
    [[Crashlytics sharedInstance] setObjectValue:[NSString stringWithFormat:@"%llu", context.ident] forKey:CrashContextContextIdent];
}

+ (void)setMessaging:(BOOL)messaging
{
    [[Crashlytics sharedInstance] setBoolValue:messaging forKey:CrashContextMessaging];
}
@end
