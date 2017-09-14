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
    
    

#import "CBILogger.h"
@import Crashlytics;
#import "CBILogFormatter.h"

// Set debug level of entire app here.
#ifdef DEBUG
const NSInteger ddLogLevel = DDLogLevelVerbose;
#else
const NSInteger ddLogLevel = DDLogLevelOff;
#endif

static CBILogFormatter *_sharedFormatter = nil;

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
    _sharedFormatter = [CBILogFormatter new];
    [[DDTTYLogger sharedInstance] setLogFormatter:_sharedFormatter];
    [[CBILogger sharedInstance] setLogFormatter:_sharedFormatter];
    
    // only log errors marked as debug to xcode console so our logging doesn't drive us insane
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelDebug];
    [DDLog addLogger:[CBILogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setLogFormatter:_sharedFormatter];
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
        if (_sharedFormatter) {
            logMsg = [_sharedFormatter formatLogMessage:logMessage];
        }
        
        CLSLog(@"%@",logMsg);
    }
}

@end
