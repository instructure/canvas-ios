//
//  CSGLogFormatter.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 3/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import "CSGLogFormatter.h"

@implementation CSGLogFormatter

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
    
    return [NSString stringWithFormat:@"[%@][%@ %@][Line %lu] %@",
            logLevel,
            logMessage.fileName,
            logMessage.function,
            (unsigned long)logMessage->_line,
            logMessage->_message];
}

@end
