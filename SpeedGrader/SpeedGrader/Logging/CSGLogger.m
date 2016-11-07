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
