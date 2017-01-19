//
//  CKIOutcomeLink.h
//  CanvasKit
//
//  Created by Brandon Pluim on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

@class CKIOutcomeGroup;
@class CKIOutcome;

@interface CKIOutcomeLink : CKIModel

/**
 The context type of the outcome.
 */
@property (nonatomic, copy) NSString *contextType;

/**
 The context owning the outcome. may be null for global outcomes.
 */
@property (nonatomic, copy) NSString *contextID;

/**
 The URL for fetching/updating the outcome
 */
@property (nonatomic, copy) NSString *url;

/**
 OutcomeGroup object representing the outcome group of this outcome link
 */
@property (nonatomic, copy) CKIOutcomeGroup *outcomeGroup;

/**
 Abbreviated outcome object representing the outcome linked to
 */
@property (nonatomic, copy) CKIOutcome *outcome;

@end
