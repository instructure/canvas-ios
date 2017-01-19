//
//  CBIDomainSuggestionTableViewController.h
//  iCanvas
//
//  Created by Jason Larsen on 2/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
- (RACSignal *)selectedTextSignal;

/**
 * This is a signal that can be subscribed to when the user asks for help in the tableview
 */
- (RACSignal *)selectedHelpSignal;

@end
