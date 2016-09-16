//
//  NSString+IN_Additions.h
//  iCanvas
//
//  Created by BJ Homer on 11/11/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (IN_Additions)

- (void)in_replaceOccurrencesOfString:(NSString *)needle withString:(NSString *)replacement;

@end
