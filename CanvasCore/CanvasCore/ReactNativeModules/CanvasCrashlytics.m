//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// Modified from https://github.com/corymsmith/react-native-fabric
#import "CanvasCrashlytics.h"
#import <Firebase/Firebase.h>
#import <os/log.h>
#import "RCTLog.h"

@implementation CanvasCrashlytics
@synthesize bridge = _bridge;

NSString *const DefaultDomain = @"com.instructure.icanvas";
NSInteger const DefaultCode = 999;

RCT_EXPORT_MODULE();

+ (void)setupForReactNative {
    // Handle notification from Developer Menu "Force Native Crash" action
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FakeCrash" object:nil queue:nil usingBlock:^(NSNotification *note) {
        assert(NO);
    }];

    RCTSetLogThreshold(RCTLogLevelFatal);
    RCTSetLogFunction(^(RCTLogLevel level, RCTLogSource source, NSString *fileName, NSNumber *lineNumber, NSString *message) {

        NSString *log = RCTFormatLog([NSDate date], level, fileName, lineNumber, message);

#ifdef DEBUG
        fprintf(stderr, "%s\n", log.UTF8String);
        fflush(stderr);
#else
        [[FIRCrashlytics crashlytics] logWithFormat:@"REACT LOG: %s", log.UTF8String];
#endif

        int logType;
        switch(level) {
            case RCTLogLevelTrace:
                logType = OS_LOG_TYPE_DEBUG;
                break;
            case RCTLogLevelInfo:
                logType = OS_LOG_TYPE_INFO;
                break;
            case RCTLogLevelWarning:
                logType = OS_LOG_TYPE_DEFAULT;
                break;
            case RCTLogLevelError:
                logType = OS_LOG_TYPE_ERROR;
                break;
            case RCTLogLevelFatal:
                logType = OS_LOG_TYPE_FAULT;
                break;
        }
        
        os_log_with_type(OS_LOG_DEFAULT, logType, "%s", message.UTF8String);
    });
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(log:(NSString *)message)
{
    [[FIRCrashlytics crashlytics] logWithFormat:@"%@", message];
}

RCT_EXPORT_METHOD(recordError:(NSDictionary *)error)
{
    NSInteger code;
    NSString *domain;
    NSObject *codeObject = [error objectForKey:@"code"];
    if (codeObject && [codeObject isKindOfClass:NSNumber.class])
        code = [(NSNumber *)codeObject intValue];
    else
        code = DefaultCode;
    if ([error objectForKey:@"domain"])
        domain = [error valueForKey:@"domain"];
    else
        domain = DefaultDomain;

    NSError *error2 = [NSError errorWithDomain:domain code:code userInfo:error];
    [FIRCrashlytics.crashlytics recordError:error2];
}

RCT_EXPORT_METHOD(crash)
{
    assert(NO);
}

RCT_EXPORT_METHOD(throwException)
{
    assert(NO);
}

RCT_EXPORT_METHOD(setUserIdentifier:(NSString *)userIdentifier)
{
    [[FIRCrashlytics crashlytics] setUserID:userIdentifier];
}

RCT_EXPORT_METHOD(setBool:(NSString *)key value:(BOOL)boolValue)
{
    [[FIRCrashlytics crashlytics] setCustomValue:[NSNumber numberWithBool:boolValue] forKey:key];
}

RCT_EXPORT_METHOD(setString:(NSString *)key value:(NSString *)stringValue)
{
    [[FIRCrashlytics crashlytics] setCustomValue:stringValue forKey:key];
}

@end
