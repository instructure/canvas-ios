//
//  CXHTMLDocument.m
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

// This is an experiment to see if we can utilize the HTMLParser functionality
// of libXML to serve as a XHTML parser, I question if this is a good idea or not
// need to test some of the following 
// [-] How are xml namespaces handled
// [-] Can we support DTD
// [-] 

#import "CXHTMLDocument.h"

#include <libxml/parser.h>
#include <libxml/htmlparser.h>
#include <libxml/HTMLtree.h>
#include <libxml/xpath.h>

#import "CXMLNode_PrivateExtensions.h"
#import "CXMLElement.h"

#if TOUCHXMLUSETIDY
#import "CTidy.h"
#endif /* TOUCHXMLUSETIDY */

@implementation CXHTMLDocument


// Differs from initWithXMLString by using libXML's HTML parser, which automatically decodes XHTML/HTML entities found within the document
// which eliminates the need to resanitize strings extracted from the document
// libXML treats a htmlDocPtr the same as xmlDocPtr
- (id)initWithXHTMLString:(NSString *)inString options:(NSUInteger)inOptions error:(NSError **)outError
{
#pragma unused (inOptions)
	if ((self = [super init]) != NULL)
	{
		NSError *theError = NULL;

		htmlDocPtr theDoc = htmlParseDoc(BAD_CAST[inString UTF8String], xmlGetCharEncodingName(XML_CHAR_ENCODING_UTF8));
    
		if (theDoc != NULL)
		{
      
      // TODO: change code to not depend on XPATH, should be a task simple enough to do
      // alternatively see if we can prevent the HTML parser from adding implied tags
      
      xmlXPathContextPtr xpathContext = xmlXPathNewContext (theDoc);
      
      xmlXPathObjectPtr xpathObject = NULL;
      if (xpathContext)
        xpathObject = xmlXPathEvalExpression (BAD_CAST("/html/body"), xpathContext);
      
      xmlNodePtr bodyNode = NULL;
      if (xpathObject && xpathObject->nodesetval->nodeMax)
        bodyNode = xpathObject->nodesetval->nodeTab[0];
      
      // TODO: Determine if this is sufficient to handle memory in libXML, is the old root removed / deleted, etc
      if (bodyNode)
        xmlDocSetRootElement(theDoc, bodyNode->children);
      
      _node = (xmlNodePtr)theDoc;
      NSAssert(_node->_private == NULL, @"TODO");
      _node->_private = self; // Note. NOT retained (TODO think more about _private usage)

      if (xpathObject)
        xmlXPathFreeObject (xpathObject);
      
      if (xpathContext)
        xmlXPathFreeContext (xpathContext);
    }
		else
		{
			xmlErrorPtr theLastErrorPtr = xmlGetLastError();
			
			NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
																	 theLastErrorPtr ? [NSString stringWithUTF8String:theLastErrorPtr->message] : @"unknown", NSLocalizedDescriptionKey,
																	 NULL];
			
			theError = [NSError errorWithDomain:@"CXMLErrorDomain" code:1 userInfo:theUserInfo];
			
			xmlResetLastError();
		}
		
		if (outError)
			*outError = theError;
		
		if (theError != NULL)
		{
			[self release];
			self = NULL;
		}
	}
	return(self);
}

- (id)initWithXHTMLData:(NSData *)inData encoding:(NSStringEncoding)encoding options:(NSUInteger)inOptions error:(NSError **)outError
{
#pragma unused (inOptions)
  if ((self = [super init]) != NULL)
	{
    NSError *theError = NULL;
    
    if (theError == NULL)
		{
      xmlDocPtr theDoc = NULL;
      if (inData && inData.length > 0)
			{
        CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(encoding);
        CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
        const char *enc = CFStringGetCStringPtr(cfencstr, 0);
        theDoc = htmlReadMemory([inData bytes], [inData length], NULL, enc, HTML_PARSE_NONET | HTML_PARSE_NOBLANKS | HTML_PARSE_NOWARNING);
			}
      
      if (theDoc != NULL)
			{
        _node = (xmlNodePtr)theDoc;
        _node->_private = self; // Note. NOT retained (TODO think more about _private usage)
			}
      else
			{
        theError = [NSError errorWithDomain:@"CXMLErrorDomain" code:-1 userInfo:NULL];
			}
		}
    
    if (outError)
      *outError = theError;
    
    if (theError != NULL)
		{
      [self release];
      self = NULL;
		}
	}
  return(self);
}



@end
