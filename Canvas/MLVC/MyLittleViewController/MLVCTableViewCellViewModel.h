//
//  MLVCTableViewCellViewModel.h
//  MyLittleViewController
//
//  Created by derrick on 10/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLVCTableViewController;

@protocol MLVCTableViewCellViewModel <NSObject>
- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (BOOL)tableViewController:(MLVCTableViewController *)controller shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)tableViewController:(MLVCTableViewController *)controller willSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableViewController:(MLVCTableViewController *)controller heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)tableViewController:(MLVCTableViewController *)controller canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewController:(MLVCTableViewController *)tableViewController commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)tableViewController:(MLVCTableViewController *)tableViewController titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
