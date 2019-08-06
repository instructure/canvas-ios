//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *andMoreStringTemplate = NSLocalizedStringFromTableInBundle(@"%d more", nil, bundle, @"In the context 'Joe, Fred, ((25 more))'");
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
        [result appendFormat:NSLocalizedStringFromTableInBundle(@"%d %@", nil, bundle, @"A number and a collective noun, like '5 pigs'"), self.count, collectiveNoun];
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
