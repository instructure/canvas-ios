//
//  CSGLogger.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 3/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import "CSGLogger.h"
#import <Crashlytics/Crashlytics.h>

@implementation CSGLogger

+ (CSGLogger *)sharedInstance {
    static dispatch_once_t pred = 0;
    static CSGLogger *_sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = nil;
    logMsg = logMessage->_message;
    
    if (logMsg != nil) {
        if (_logFormatter != nil) {
            logMsg = [_logFormatter formatLogMessage:logMessage];
        }
        
        CLSLog(@"%@",logMsg);
    }
    
    return;
}


@end
