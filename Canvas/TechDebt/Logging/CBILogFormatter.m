//
//  CBILogFormatter.m
//  iCanvas
//
//  Created by Brandon Pluim on 4/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBILogFormatter.h"

@implementation CBILogFormatter


- (NSString*)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString* logLevel = nil;
    switch (logMessage->_level) {
        case DDLogLevelError:
            logLevel = @"E";
            break;
        case DDLogLevelWarning:
            logLevel = @"W";
            break;
        case DDLogLevelInfo:
            logLevel = @"I";
            break;
        case DDLogLevelDebug:
            logLevel = @"D";
            break;
        default:
            logLevel = @"V";
            break;
    }
    
    return [NSString stringWithFormat:@"[%@][%@ %@][Line %d] %@",
            logLevel,
            logMessage->_fileName,
            logMessage->_function,
            logMessage->_line,
            logMessage->_message];
}
@end