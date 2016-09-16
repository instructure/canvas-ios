//
//  Analytics.h
//  Canvas
//
//  Created by Derrick Hathaway on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCanvasConstants.h"

@interface Analytics : NSObject
+ (void)prepare;
+ (void)logScreenView:(NSString*)screenName;
@end
