//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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