//
// Created by jasonl on 3/20/13.
//


#import "CKModuleItem.h"
#import "CKModuleItemCompletionRequirement.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKModuleItem

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        NSDictionary *dict = [NSDictionary safeDictionaryWithDictionary:info];

        _title = dict[@"title"];
        _ident = [ dict[@"id"] unsignedLongLongValue];
        _indentationLevel = [dict[@"indent"] unsignedIntegerValue];

        [self setTypeFromString:dict[@"type"]];

        _htmlURL = [NSURL URLWithString:dict[@"html_url"]];
        NSString *urlString = dict[@"url"];
        if (urlString) {
            _canvasObjectURL = [NSURL URLWithString:urlString];
        }

        _completionRequirement = [CKModuleItemCompletionRequirement requirementWithInfo:dict[@"completion_requirement"]];
    }
    return self;
}

- (void)setTypeFromString:(NSString *)typeString {
    if ([typeString isEqualToString:@"File"]) {
            _type = CKModuleItemTypeFile;
    }
    else if ([typeString isEqualToString:@"Page"]) {
        _type = CKModuleItemTypePage;
    }
    else if ([typeString isEqualToString:@"Discussion"]) {
        _type = CKModuleItemTypeDiscussion;
    }
    else if ([typeString isEqualToString:@"Assignment"]) {
        _type = CKModuleItemTypeAssignment;
    }
    else if ([typeString isEqualToString:@"Quiz"]) {
        _type = CKModuleItemTypeQuiz;
    }
    else if ([typeString isEqualToString:@"SubHeader"]) {
        _type = CKModuleItemTypeSubHeader;
    }
    else if ([typeString isEqualToString:@"ExternalUrl"]) {
        _type = CKModuleItemTypeExternalURL;
    }
    else if ([typeString isEqualToString:@"ExternalTool"]) {
        _type = CKModuleItemTypeExternalTool;
    }
}


- (NSUInteger)hash {
    return self.ident;
}

+ (CKModuleItem *)itemWithInfo:(NSDictionary *)info {
    return [[CKModuleItem alloc] initWithInfo:info];
}

@end