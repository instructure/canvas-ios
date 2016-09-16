//
//  NSString_stripHTML.h
//  iCanvas
//
//  Created by BJ Homer on 7/28/11.
//  Copyright 2011 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IN_StripHTML)

- (NSString *)in_stringByStrippingHTMLTags;

@end
