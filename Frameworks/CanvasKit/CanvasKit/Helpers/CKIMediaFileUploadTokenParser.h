//
//  CKIMediaFileUploadTokenParser.h
//  CanvasKit
//
//  Created by Rick Roberts on 11/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKIMediaFileUploadTokenParser : NSObject

- (id)initWithXMLParser:(NSXMLParser *)parser;
- (void)parseWithSuccess:(void(^)(NSString *uploadID))success failure:(void(^)(NSError *error))failure;

@end
