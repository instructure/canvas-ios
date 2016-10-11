//
//  NSURL+QueryParams.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 12/16/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryParams)

- (NSDictionary *)queryParameters;

@end
