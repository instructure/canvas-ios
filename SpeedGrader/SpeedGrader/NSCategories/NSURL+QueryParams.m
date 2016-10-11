//
//  NSURL+QueryParams.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 12/16/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "NSURL+QueryParams.h"

@implementation NSURL (QueryParams)

- (NSDictionary *)queryParameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [[self query] componentsSeparatedByString:@"&"];
    
    for (NSString *component in queryComponents) {
        NSArray *keyValuePair = [component componentsSeparatedByString:@"="];
        if ([keyValuePair count] != 2) {
            NSLog(@"malformatted parameter. skipping. %@",keyValuePair);
            continue;
        }
        NSString *key = [[keyValuePair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [[keyValuePair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if ([key hasSuffix:@"[]"]) {
            NSMutableArray *valuesForKey = [parameters objectForKey:key];
            if (!valuesForKey) {
                valuesForKey = [NSMutableArray array];
                [parameters setObject:valuesForKey forKey:key];
            }
            [valuesForKey addObject:value];
        }
        else {
            [parameters setObject:value forKey:key];
        }
    }
    
    return parameters;
}

@end
