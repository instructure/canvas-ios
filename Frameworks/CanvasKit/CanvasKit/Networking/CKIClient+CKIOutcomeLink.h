//
//  CKIClient+CKIOutcomeLink.h
//  CanvasKit
//
//  Created by Brandon Pluim on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKIOutcomeGroup;

@interface CKIClient (CKIOutcomeLink)

- (RACSignal *)fetchOutcomeLinksForOutcomeGroup:(CKIOutcomeGroup *)group;

@end
