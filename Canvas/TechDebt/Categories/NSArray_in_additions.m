//
//  NSArray_in_additions.m
//  iCanvas
//
//  Created by BJ Homer on 10/4/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "NSArray_in_additions.h"

@implementation NSArray (IN_Additions)


- (NSString *)in_componentsJoinedByString:(NSString *)joiner
                  componentCollectiveNoun:(NSString *)collectiveNoun
                             maximumWidth:(CGFloat)maxWidth
                                   inFont:(UIFont *)font {
    if (self.count == 0) {
        return @"";
    }
    if (self.count == 1) {
        return self[0];
    }
    
    NSString *andMoreStringTemplate = NSLocalizedString(@"%d more", @"In the context 'Joe, Fred, ((25 more))'");
    NSString *trailerTemplate = [joiner stringByAppendingString:andMoreStringTemplate];
    
    CGFloat roughTailerLength = [trailerTemplate sizeWithAttributes:@{NSFontAttributeName: font}].width;
    
    NSMutableString *result = [NSMutableString string];
    
    NSUInteger includedEntries = 0;
    NSMutableString *nextAppendage = [NSMutableString string];
    
    CGFloat currentWidth = 0.0;
    for (NSString *str in self) {
        [nextAppendage setString:@""];
        if (includedEntries > 0) {
            [nextAppendage appendString:joiner];
        }
        
        [nextAppendage appendString:str];
        
        CGFloat appendageWidth = [nextAppendage sizeWithAttributes:@{NSFontAttributeName: font}].width;
        
        CGFloat trailerWidth = (includedEntries < self.count ? roughTailerLength : 0);
        if (currentWidth + appendageWidth + trailerWidth < maxWidth) {
            ++includedEntries;
            [result appendString:nextAppendage];
        }
        else {
            break;
        }
        
        currentWidth = [result sizeWithAttributes:@{NSFontAttributeName: font}].width;
    }
    if (includedEntries == 0) {
        [result appendFormat:NSLocalizedString(@"%d %@", @"A number and a collective noun, like '5 pigs'"), self.count, collectiveNoun];
    }
    else if (includedEntries < self.count) {
        [result appendFormat:trailerTemplate, self.count - includedEntries];
    }
    return result;
}


- (NSArray *)in_arrayByApplyingBlock:(id (^)(id obj))block {
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id obj in self) {
        id newObj = block(obj);
        if (newObj) {
            [newArray addObject:newObj];
        }
    }
    return newArray;
}

- (id)in_reduceUsingBlock:(id (^)(id previousReduction, id currentObject))block {
    id reduction = nil;
    for (id obj in self) {
        reduction = block(reduction, obj);
    }
    return reduction;
}


@end
