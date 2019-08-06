//
//  CXMLDocument.h
//  TouchCode
//
//  Created by Jonathan Wight on 03/07/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CXMLNode.h"

enum {
	CXMLDocumentTidyHTML = 1 << 9, // Based on NSXMLDocumentTidyHTML
	CXMLDocumentTidyXML = 1 << 10, // Based on NSXMLDocumentTidyXML
};

@class CXMLElement;

@interface CXMLDocument : CXMLNode {
	NSMutableSet *nodePool;
}

- (id)initWithData:(NSData *)inData options:(NSUInteger)inOptions error:(NSError **)outError;
- (id)initWithData:(NSData *)inData encoding:(NSStringEncoding)encoding options:(NSUInteger)inOptions error:(NSError **)outError;
- (id)initWithXMLString:(NSString *)inString options:(NSUInteger)inOptions error:(NSError **)outError;
- (id)initWithContentsOfURL:(NSURL *)inURL options:(NSUInteger)inOptions error:(NSError **)outError;
- (id)initWithContentsOfURL:(NSURL *)inURL encoding:(NSStringEncoding)encoding options:(NSUInteger)inOptions error:(NSError **)outError;

//- (NSString *)characterEncoding;
//- (NSString *)version;
//- (BOOL)isStandalone;
//- (CXMLDocumentContentKind)documentContentKind;
//- (NSString *)MIMEType;
//- (CXMLDTD *)DTD;

- (CXMLElement *)rootElement;

- (NSData *)XMLData;
- (NSData *)XMLDataWithOptions:(NSUInteger)options;

//- (id)objectByApplyingXSLT:(NSData *)xslt arguments:(NSDictionary *)arguments error:(NSError **)error;
//- (id)objectByApplyingXSLTString:(NSString *)xslt arguments:(NSDictionary *)arguments error:(NSError **)error;
//- (id)objectByApplyingXSLTAtURL:(NSURL *)xsltURL arguments:(NSDictionary *)argument error:(NSError **)error;

- (id)XMLStringWithOptions:(NSUInteger)options;

@end
