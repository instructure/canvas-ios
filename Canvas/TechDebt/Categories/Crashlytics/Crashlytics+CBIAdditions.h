//
//  Crashlytics+Additions.h
//  iCanvas
//
//  Created by Miles Wright on 2/27/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

@interface Crashlytics (CBIAdditions)

+ (void)prepare;
+ (void)setDebugInformation;

@end
