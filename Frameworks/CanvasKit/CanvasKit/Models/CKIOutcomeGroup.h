//
//  CKIOutcomeGroup.h
//  CanvasKit
//
//  Created by Brandon Pluim on 5/20/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

@interface CKIOutcomeGroup : CKIModel

/**
 The title for the outcome group.
 */
@property (nonatomic, copy) NSString *title;

/**
 The description for the outcome group.
 */
@property (nonatomic, copy) NSString *details;

/**
 The context type of the outcome group.
 */
@property (nonatomic, copy) NSString *contextType;

/**
 The context owning the outcome group. may be null for global outcome groups. Omitted in the abbreviated form
 */
@property (nonatomic, copy) NSString *contextID;

/**
 The URL for fetching/updating the outcome group. should be treated as opaque
 */
@property (nonatomic, copy) NSString *url;

/**
 The URL for listing/creating subgroups under the outcome group.
 */
@property (nonatomic, copy) NSString *subgroupsURL;

/**
 The URL for listing/creating outcome links under the outcome group.
 */
@property (nonatomic, copy) NSString *outcomesURL;

/**
 OutcomeGroup object representing the parent group of this outcome group, if any
 */
@property (nonatomic, copy) CKIOutcomeGroup *parent;

@end