//
//  CSGLogger.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 3/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

@import CocoaLumberjack;

@interface CSGLogger : DDAbstractLogger

+ (CSGLogger *)sharedInstance;

@end
