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

#import "CSGColorManager.h"
#import "UIColor+HexString.h"
#import "CSGUserPrefsKeys.h"
@import CanvasKit;

@implementation CSGColorManager

- (void)fetchColorDataForUserWithSuccess:(void (^)())success failure:(void (^)())failure {
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"users"];
    NSDictionary *params = @{@"ns": @"MOBILE_CANVAS_COLORS"};
    path = [path stringByAppendingFormat:@"/%@/custom_data/course_color", [TheKeymaster currentClient].currentUser.id];
    
    [[TheKeymaster currentClient] GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDictionary = responseObject;
        NSString *dataAsString = responseDictionary[@"data"];
        
        NSData *jsonData = [dataAsString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        for (NSDictionary *entry in responseArray) {
            [CSGUserPrefsKeys saveColor:[UIColor colorWithHexString:entry[@"color"]] forCourseID:[entry[@"contextId"] stringValue] sendToAPI:NO];
        }
        
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //This is a known AFNetworking error triggered by new users without any color information
        if (error.code == NSURLErrorBadServerResponse && success) {
            success();
        } else if (failure) {
            failure();
        }
    }];
}

- (void)saveColorDataForUserWithSuccess:(void (^)())success failure:(void (^)())failure {
    NSString *json = [self exportColorsAsJSON];
    NSDictionary *params = @{@"ns": @"MOBILE_CANVAS_COLORS", @"data": json};
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"users"];
    path = [path stringByAppendingFormat:@"/%@/custom_data/course_color", [TheKeymaster currentClient].currentUser.id];
    
    [[TheKeymaster currentClient] PUT:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error = %@", error);
        if (failure) {
            failure();
        }
    }];
}

#pragma mark - Helper Methods

- (NSString *) exportColorsAsJSON {
    return [self convertColorsDictionaryToJSON];
}

- (NSString *)hexStringForColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed: &r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
}

- (NSString *) convertColorsDictionaryToJSON {
    NSDictionary *colorDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:CSGColorStoreUserPrefKey];
    if (!colorDictionary) {
        return nil;
    }
    
    NSMutableArray *formattedColorArray = [NSMutableArray new];
    
    for (id key in colorDictionary) {
        
        NSData *data = [colorDictionary objectForKey:key];
        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
        
        NSDictionary *entry = @{@"color": [self hexStringForColor:color], @"contextId":  [numberFormatter numberFromString:key]};
        [formattedColorArray addObject:entry];
    }

    NSError *error = nil;
    NSData *json;
    
    if ([NSJSONSerialization isValidJSONObject:formattedColorArray]) {
        json = [NSJSONSerialization dataWithJSONObject:formattedColorArray options:NSJSONWritingPrettyPrinted error:&error];
        
        if (json != nil && error == nil) {
            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            return jsonString;
        }
    }
    
    return nil;
}

@end
