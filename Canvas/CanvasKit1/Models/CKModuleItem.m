//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

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