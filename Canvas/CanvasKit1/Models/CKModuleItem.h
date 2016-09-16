//
// Created by jasonl on 3/20/13.
//


#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKModuleItemCompletionRequirement;

//"File", "Page", "Discussion", "Assignment", "Quiz", "SubHeader",
// "ExternalUrl", "ExternalTool"

typedef enum CKModuleItemType {
    CKModuleItemTypeFile,
    CKModuleItemTypePage,
    CKModuleItemTypeDiscussion,
    CKModuleItemTypeAssignment,
    CKModuleItemTypeQuiz,
    CKModuleItemTypeSubHeader,
    CKModuleItemTypeExternalURL,
    CKModuleItemTypeExternalTool
} CKModuleItemType;


@interface CKModuleItem : CKModelObject
@property (readonly) uint64_t ident;
@property (readonly) NSString *title;
@property (readonly) NSUInteger indentationLevel;
@property (readonly) NSURL *htmlURL;
@property (readonly) NSURL *canvasObjectURL; //optional
@property (readonly) CKModuleItemCompletionRequirement *completionRequirement;
@property (readonly) CKModuleItemType type;

+ (CKModuleItem *)itemWithInfo:(NSDictionary *)dictionary;
@end