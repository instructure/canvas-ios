//
//  CBILogger.h
//  iCanvas
//
//  Created by Brandon Pluim on 4/4/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

@import CocoaLumberjack;

@interface CBILogger : DDAbstractLogger

+ (CBILogger *)sharedInstance;
+ (void)install:(id <DDLogFileManager>)logFileManager;

@end
