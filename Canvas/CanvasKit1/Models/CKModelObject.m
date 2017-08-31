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
    
    

#import "CKModelObject.h"
#import "ISO8601DateFormatter.h"
#import <objc/runtime.h>

@implementation CKModelObject

+ (void)initialize {
    [super initialize];
    if ([[self class] isEqual:[CKModelObject class]] == NO) {
        // Verify that subclasses have a -hash implementation to accompany the -isEqual: we are providing.
        [self verifyHasHashImplementation];
    }
}

- (ISO8601DateFormatter *)apiDateFormatter {
    static ISO8601DateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [ISO8601DateFormatter new];
    });
    return dateFormatter;
}


+ (void)verifyHasHashImplementation {
    Class rootClass = [CKModelObject class];
    Class currentClass = [self class];
    
    BOOL hashFound = NO;
    
    while (!hashFound && currentClass != rootClass) {
        unsigned int methodCount;
        Method *methods = class_copyMethodList(currentClass, &methodCount);
        
        for (int i=0; i<methodCount && !hashFound; ++i) {
            const char *methodName = sel_getName(method_getName(methods[i]));
            if (strcmp(methodName, "hash") == 0) {
                hashFound = YES;
            }
        }
        free(methods);
        currentClass = class_getSuperclass(currentClass);
    }
    if (!hashFound) {
        NSString *exceptionReason = [NSString stringWithFormat:
                                     @"\n*** WARNING ***\n"
                                     @"\n"
                                     @"Class %@ inherits from CKObject but does not implement -hash.\n"
                                     @"Since CKObject provides an -isEqual: implementation, this is very "
                                     @"likely to cause problems.\n"
                                     @"\n", self];
        @throw [NSException exceptionWithName:@"Missing -hash implementation" reason:exceptionReason userInfo:nil];
    }
}


- (BOOL)isEqual:(id)other {
    if ([other isMemberOfClass:[self class]] == NO) {
        return NO;
    }
    
    Class rootClass = [CKModelObject class];
    Class currentClass = [self class];
    
    BOOL comparisonFailed = NO;
    
    while (!comparisonFailed && [currentClass isSubclassOfClass:rootClass]) {
        
        NSArray *propertiesToExclude = [currentClass propertiesToExcludeFromEqualityComparison];
        
        unsigned int propCount;
        objc_property_t *propList = class_copyPropertyList(currentClass, &propCount);
        
        for (int i=0; i<propCount && !comparisonFailed; ++i) {
            objc_property_t property = propList[i];
            NSString *propName = @(property_getName(property));
            
            if ([propertiesToExclude containsObject:propName]) {
                continue;
            }
            
            char *weakAttrValue = property_copyAttributeValue(property, "W");
            if (weakAttrValue) {
                // It's a 'weak' property; don't include it in the 'isEqual:' comparison
                free(weakAttrValue);
                continue;
            }
            
            id selfVal = [self valueForKey:propName];
            id otherVal = [other valueForKey:propName];
            
            if ([selfVal isEqual:otherVal] == NO && selfVal != otherVal ) {
                comparisonFailed = YES;
            }
        }
        
        free(propList);
        
        currentClass = class_getSuperclass(currentClass);
    }
    return !comparisonFailed;
}




+ (NSArray *)propertiesToExcludeFromEqualityComparison {
    return nil;
}

@end
