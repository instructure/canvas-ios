//
//  CKIModule+ModuleProgression.h
//  iCanvas
//
//  Created by Nathan Armstrong on 4/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import <CanvasKit/CanvasKit.h>

@interface CKIModule (ModuleProgression)

- (CKIModuleItem *)moduleItemAfterModuleItem:(CKIModuleItem *)moduleItem;
- (CKIModuleItem *)moduleItemBeforeModuleItem:(CKIModuleItem *)moduleItem;

@end
