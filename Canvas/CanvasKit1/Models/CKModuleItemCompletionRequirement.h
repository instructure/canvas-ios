//
// Created by jasonl on 3/20/13.
//

#import <Foundation/Foundation.h>

typedef enum CKModuleItemCompletionRequirementType {
    CKModuleItemCompletionRequirementTypeMustView,
    CKModuleItemCompletionRequirementTypeMustSubmit,
    CKModuleItemCompletionRequirementTypeMustContribute,
    CKModuleItemCompletionRequirementTypeMinScore,
} CKModuleItemCompletionRequirementType;

@interface CKModuleItemCompletionRequirement : NSObject
- (id)initWithInfo:(NSDictionary *)info;
+ (id)requirementWithInfo:(NSMutableDictionary *)info;

@property (readonly) CKModuleItemCompletionRequirementType type;
@property (readonly) float minScore; // only valid when of type MinScore
@property (readonly) BOOL completed; // only valid if user is a student
@end