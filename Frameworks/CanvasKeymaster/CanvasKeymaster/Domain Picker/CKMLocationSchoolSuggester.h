//
//  CKMLocationSchoolSuggester.h
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface CKMLocationSchoolSuggester : NSObject

/**
 * The current value of the domain. This will determine what values, if any, are sent back through the suggestions stream.
 */
@property (nonatomic, copy) NSString *schoolSearchString;

/**
 * A stream of arrays of strings, where each array of strings is a list of the possible autocompletions to be displayed.
 * This will be updated and send back values as appropriate when domainString is updated
 */
- (RACSignal *)suggestionsSignal;

@end
