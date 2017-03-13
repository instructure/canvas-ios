//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CKIModel.h"

@class CKIModule;

/**
 The module item is a file.
 
 @see CKIFile
 */
extern NSString * const CKIModuleItemTypeFile;

/**
 The module item is a page.
 
 @see CKIPage
 */
extern NSString * const CKIModuleItemTypePage;

/**
 The module item is a dicussion.
 
 @see CKIDicussion
 */
extern NSString * const CKIModuleItemTypeDiscussion;

/**
 The module item is an assignment.
 
 @see CKIAssignment
 */
extern NSString * const CKIModuleItemTypeAssignment;

/**
 The module item is a quiz.
 
 @see CKIQuiz.
 */
extern NSString * const CKIModuleItemTypeQuiz;

/**
 The module item is a text subheader describing a subsection
 in a module.
 */
extern NSString * const CKIModuleItemTypeSubHeader;

/**
 The module item is a URL to another web page.
 */
extern NSString * const CKIModuleItemTypeExternalURL;

/**
 The module item is a URL to an LTI tool.
 */
extern NSString * const CKIModuleItemTypeExternalTool;

/**
 Must view the item to fulfill completion requirement.
 */
extern NSString * const CKIModuleItemCompletionRequirementMustView;
/**
 Must make a submission to fulfill completion requirement.
 */
extern NSString * const CKIModuleItemCompletionRequirementMustSubmit;
/**
 Must contribute to fulfill completion requirement.
 */
extern NSString * const CKIModuleItemCompletionRequirementMustContribute;
/**
 Must achieve a minimum score to fulfill completion requirement.
 
 @see minimumScore
 */
extern NSString * const CKIModuleItemCompletionRequirementMinimumScore;

/**
 Must manually mark the module as done.
 */
extern NSString * const CKIModuleItemCompletionRequirementMustMarkDone;

/**
 An individual item inside a CKIModule. Can be a file, wiki page,
 discussion, assignment, quiz, text subheader, external URL, or
 external LTI tool.
 */
@interface CKIModuleItem : CKIModel

/**
 The title of the item.
 */
@property (nonatomic, copy) NSString *title;

/**
 The type of the item: File, Page, Discussion, Assignment,
 Quiz, SubHeader, ExternalUrl, or ExternalTool.
 */
@property (nonatomic, copy) NSString *type;

/**
 The ID of the object referred to, unless it is an external URL,
 external tool, or subheader.
 
 @see external_url for external tools and URLs.
 @note Subheaders do not have IDs; they are just a title.
 */
@property (nonatomic, readonly) NSString *itemID;

// These properties store JSON data to be used
// to create the derived itemID property.
@property (nonatomic, readonly) NSString *contentID;
@property (nonatomic, strong) NSURL *pageID;

/**
 Link to the item's web page in Canvas.
 */
@property (nonatomic, strong) NSURL *htmlURL;

/**
 Link to the item's web API URL.
 */
@property (nonatomic, strong) NSURL *apiURL;

/**
 The URL of the external LTI tool or URL.
 */
@property (nonatomic, strong) NSURL *externalURL;

#pragma mark - Completion requirements

/**
 The requirement to complete this module item, if any: must either
 view the item, make a submission, contribute, or achieve a minimum
 score.
 
 @see CKIModuleItemCompletionRequirementMustView
 CKIModuleItemCompletionRequirementMustSubmit
 CKIModuleItemCompletionRequirementMustContribute
 CKIModuleItemCompletionRequirementMinimumScore
 @see minimumScore if this is a CKIModuleItemCompletionRequirementMinimumScore
 */
@property (nonatomic, copy) NSString *completionRequirement;

/**
 The minimum score that must be achieved to complete this item.
 
 @note Only present if completionRequirement is of type
 CKIModuleItemCompletionRequirementMinimumScore
 
 @see completionRequirement
 */
@property (nonatomic) double minimumScore;

/**
 This module item's completion requirement has been met.
 
 @see completionRequirement
 @warning This is only valid if there is a completion requirement. Some
 items have no completion requirements, and therefore are neither completed,
 nor incomplete.
 */
@property (nonatomic) BOOL completed;

#pragma margk - Content Details

@property (nonatomic) double pointsPossible;

@property (nonatomic, strong) NSDate *dueAt;

@property (nonatomic, strong) NSDate *unlockAt;

@property (nonatomic, strong) NSDate *lockAt;


@property (nonatomic) CKIModule *context;
@end
