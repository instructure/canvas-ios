//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "CKIMediaFileUploadTokenParser.h"

@interface CKIMediaFileUploadTokenParser() <NSXMLParserDelegate>
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSString *element;
@property (nonatomic, strong) NSString *uploadID;
@end

@implementation CKIMediaFileUploadTokenParser

- (id)initWithXMLParser:(NSXMLParser *)parser {
    self = [super init];
    if (self) {
        _parser = parser;
    }
    
    return self;
}

- (void)parseWithSuccess:(void(^)(NSString *uploadID))success failure:(void(^)(NSError *error))failure {
    
    self.parser.delegate = self;
    
    BOOL parseSuccess = [self.parser parse];
    if (parseSuccess && self.uploadID.length > 0) {
        if (success) {
            success(self.uploadID);
        }
    } else {
        if (failure) {
            failure([NSError errorWithDomain:@"com.instructure.speedgrader.error" code:0001 userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse upload id"}]);
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.element = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    self.element = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.element isEqualToString:@"id"]) {
        self.uploadID = string;
    }
}

@end
