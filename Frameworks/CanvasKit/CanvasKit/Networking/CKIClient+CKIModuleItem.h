//
//  CKIClient+CKIModuleItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKIModule;
@class CKIModuleItem;
@class RACSignal;

@interface CKIClient (CKIModuleItem)

- (RACSignal *)fetchModuleItem:(NSString *)moduleItemID forModule:(CKIModule *)module;

- (RACSignal *)fetchModuleItemsForModule:(CKIModule *)module;

- (RACSignal *)markModuleItemAsDone:(CKIModuleItem *)item;

- (RACSignal *)markModuleItemAsRead:(CKIModuleItem *)item;

@end
