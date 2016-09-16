//
//  iCanvasErrorHandler.h
//  iCanvas
//
//  Created by BJ Homer on 8/23/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iCanvasErrorHandler : NSObject

+ (id)sharedErrorHandler;

- (void)logError:(NSError *)error;
- (void)presentError:(NSError *)error;

@end
