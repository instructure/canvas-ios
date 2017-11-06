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

#import <UIKit/UIKit.h>

@class RACSignal;

@interface CKMDomainSuggestionTableViewController : UITableViewController

/**
* Set this to whatever is the current value of the text. This will
* update the UITableView to show matching results
*/
@property (nonatomic, copy) NSString *query;

/**
* This signal will send an NSString with the value of the domain when
* a user selects a cell with a value in it.
*/
- (RACSignal *)selectedSchoolSignal;

/**
 * This is a signal that can be subscribed to when the user asks for help in the tableview
 */
- (RACSignal *)selectedHelpSignal;

@end
