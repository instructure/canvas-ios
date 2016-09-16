//
//  CBILogger.m
//  iCanvas
//
//  Created by Brandon Pluim on 4/4/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBILogger.h"
@import Crashlytics;
#import "CBILogFormatter.h"

// Set debug level of entire app here.
#ifdef DEBUG
const NSInteger ddLogLevel = DDLogLevelVerbose;
#else
const NSInteger ddLogLevel = DDLogLevelOff;
#endif

@implementation CBILogger

+ (CBILogger *)sharedInstance {
    static dispatch_once_t pred = 0;
    static CBILogger *_sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

+ (void)install:(id <DDLogFileManager>)logFileManager {
    // Set up DDLog :)
    CBILogFormatter *formatter = [CBILogFormatter new];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    [[CBILogger sharedInstance] setLogFormatter:formatter];
    
    // only log errors marked as debug to xcode console so our logging doesn't drive us insane
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelDebug];
    [DDLog addLogger:[CBILogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setLogFormatter:formatter];
    fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 0;            // disable time based rolling
    fileLogger.maximumFileSize = 1024 * 100;    // 100KB;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 1;  // only need one file
    [DDLog addLogger:fileLogger];

}

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = nil;
    logMsg = logMessage->_message;
    
    if (logMsg != nil) {
        id<DDLogFormatter> formatter = [[DDLog allLoggers].firstObject logFormatter];
        if (formatter != nil) {
            logMsg = [formatter formatLogMessage:logMessage];
        }
        
        CLSLog(@"%@",logMsg);
    }
    
    return;
}

@end
