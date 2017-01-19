//
// Created by Jason Larsen on 2/25/14.
// Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

/**
* A very suggestive class. Set the domainString value on it, and it will in turn send values back through
* the suggestionsSignal.
*/
@interface CKMDomainSuggester : NSObject

/**
* The current value of the domain. This will determine what values, if any, are sent back through the suggestions stream.
*/
@property (nonatomic, copy) NSString *domainString;

/**
* Save domain to NSUserDefaults so that we can remember it forever and suggest it in the future.
*/
- (void)saveDomain:(NSURL *)domain;

/**
* A stream of arrays of strings, where each array of strings is a list of the possible autocompletions to be displayed.
* This will be updated and send back values as appropriate when domainString is updated
*/
- (RACSignal *)suggestionsSignal;

@end