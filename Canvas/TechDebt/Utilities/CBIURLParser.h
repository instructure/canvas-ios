//
//  CBIURLParser.h
//  iCanvas
//
//  Created by Rick Roberts on 2/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBIURLParser : NSObject

@property (nonatomic, strong) NSArray *variables;


- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;


@end
