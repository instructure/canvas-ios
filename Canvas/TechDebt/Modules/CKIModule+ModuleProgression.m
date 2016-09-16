//
//  CKIModule+ModuleProgression.m
//  iCanvas
//
//  Created by Nathan Armstrong on 4/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import "CKIModule+ModuleProgression.h"

@implementation CKIModule (ModuleProgression)

- (CKIModuleItem *)moduleItemAfterModuleItem:(CKIModuleItem *)moduleItem
{
    NSInteger index = [self.items indexOfObject:moduleItem];

    if (index == NSNotFound) {
        return nil;
    }

    for (NSInteger i = index + 1; i < [self.items count]; i++) {
        if (i >= 0 && i < [self.items count]) {
            CKIModuleItem *item = [self.items objectAtIndex:i];
            if (![item.type isEqualToString:CKIModuleItemTypeSubHeader]) {
                return item;
            }
        }
    }

    return nil;
}

- (CKIModuleItem *)moduleItemBeforeModuleItem:(CKIModuleItem *)moduleItem
{
    NSInteger index = [self.items indexOfObject:moduleItem];

    if (index == NSNotFound) {
        return nil;
    }

    for (NSInteger i = index - 1; i >= 0; i--) {
        if (i >= 0 && i < [self.items count]) {
            CKIModuleItem *item = [self.items objectAtIndex:i];
            if (![item.type isEqualToString:CKIModuleItemTypeSubHeader]) {
                return item;
            }
        }
    }

    return nil;
}

@end
