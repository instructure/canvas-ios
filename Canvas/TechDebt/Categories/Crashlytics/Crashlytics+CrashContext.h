//
//  Crashlytics+CrashContext.h
//  iCanvas
//
//  Created by derrick on 3/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

@class CKAPICredentials, CKContextInfo;
@interface Crashlytics (CrashContext)
+ (void)setCredentials:(CKAPICredentials *)creds;
+ (void)setContext:(CKContextInfo *)context;
+ (void)setMessaging:(BOOL)messaging;
@end
