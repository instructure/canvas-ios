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
    
    

#import "NSString_stripHTML.h"
#import <UIKit/UIKit.h>

@interface ParserHelper : NSObject <NSXMLParserDelegate> {
@private
    NSString *initialString;
    NSXMLParser *parser;
    NSMutableString *finalString;
    BOOL needsInsertedWhitespace;
    NSString *lastCharacterFound;
}

- (NSString *)htmlStrippedString:(NSString *)string;

@end

@implementation ParserHelper

- (NSString *)htmlStrippedString:(NSString *)string {

    static UIWebView *htmlEntityStripper;
    if (htmlEntityStripper == nil) {
        htmlEntityStripper  = [[UIWebView alloc] init];
    }
    initialString = string;
    
    
    NSString *escapedString = [[string stringByReplacingOccurrencesOfString:@"\n" withString:@" "] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    // Convert HTML entities to real characters, since XML only recognizes a couple of them
    // However, make sure to escape '&amp;' so we're not left with a naked '&' in the XML
    NSString *javascript = [NSString stringWithFormat:
                            @"var ta=document.createElement('textarea');"
                            @"ta.innerHTML=\"%@\".replace(/&amp;/g, '&amp;amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');"
                            @"ta.value;",
                            escapedString];
    NSString *stringWithHTMLEntitiesEscaped = [htmlEntityStripper stringByEvaluatingJavaScriptFromString:javascript];
    
    NSString *wrappedString = [NSString stringWithFormat:@"<dummy>%@</dummy>", stringWithHTMLEntitiesEscaped];
    finalString = [NSMutableString new];
    parser = [[NSXMLParser alloc] initWithData:[wrappedString dataUsingEncoding:NSUTF8StringEncoding]];
    parser.delegate = self;
    [parser parse];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)finalString);
    return finalString;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (string.length == 0) {
        return;
    }
    if (needsInsertedWhitespace) {
        string = [@" " stringByAppendingString:string];
        needsInsertedWhitespace = NO;
    }
    [finalString appendString:string];
    lastCharacterFound = [string substringFromIndex:string.length-1];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (lastCharacterFound && [lastCharacterFound rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location == NSNotFound) {
        needsInsertedWhitespace = YES;
    }
}

- (void)parser:(NSXMLParser *)aParser parseErrorOccurred:(NSError *)parseError {
    NSInteger code = [parseError code];
    if (code == NSXMLParserTagNameMismatchError) {
        // This is likely just a <br> instead of <br />
        return;
    }
    finalString = [initialString mutableCopy];
    [aParser abortParsing];
}

@end

@implementation NSString (IN_StripHTML)

- (NSString *)in_stringByStrippingHTMLTags {
    ParserHelper *helper = [ParserHelper new];
    return [helper htmlStrippedString:self];
}

@end
