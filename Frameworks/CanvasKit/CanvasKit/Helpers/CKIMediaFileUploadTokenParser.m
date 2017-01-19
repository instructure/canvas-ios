//
//  CKIMediaFileUploadTokenParser.m
//  CanvasKit
//
//  Created by Rick Roberts on 11/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
