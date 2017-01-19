//
//  CKIOutcome.h
//  CanvasKit
//
//  Created by Brandon Pluim on 5/20/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

@class CKIOutcomeGroup;

@interface CKIOutcome : CKIModel

/**
 The title for the outcome.
 */
@property (nonatomic, copy) NSString *title;

/**
 The courseID for the outcome.
 */
@property (nonatomic, copy) NSString *courseID;

/**
 The description for the outcome.
 */
@property (nonatomic, copy) NSString *details;

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
 maximum points possible.
 */
@property (nonatomic, copy) NSNumber *pointsPossible;

/**
 points necessary to demonstrate mastery outcomes.
 */
@property (nonatomic, copy) NSNumber *masteryPoints;


@end