
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
