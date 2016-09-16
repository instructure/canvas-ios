//
//  CKCanvasAPIResponse.h
//  CanvasKit
//
//  Created by BJ Homer on 12/2/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CXMLDocument;

@interface CKCanvasAPIResponse : NSHTTPURLResponse

- initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data;

@property (readonly, copy) NSData *data;
@property (readonly, copy) id JSONValue;
@property (readonly, copy) CXMLDocument *XMLValue;
@property (readonly, copy) NSDictionary *ICSValue;

@end
