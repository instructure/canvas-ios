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
