//
//  NSArray_in_additions.h
//  iCanvas
//
//  Created by BJ Homer on 10/4/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSArray (IN_Additions)

- (NSString *)in_componentsJoinedByString:(NSString *)joiner
                  componentCollectiveNoun:(NSString *)collectiveNoun
                             maximumWidth:(CGFloat)maxWidth
                                   inFont:(UIFont *)font;

- (NSArray *)in_arrayByApplyingBlock:(id (^)(id obj))block;

- (id)in_reduceUsingBlock:(id (^)(id previousReduction, id currentObject))block;

@end
