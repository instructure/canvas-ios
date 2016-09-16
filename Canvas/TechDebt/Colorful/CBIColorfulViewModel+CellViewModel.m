//
//  CBIColorfulViewModel+TableViewCellAdapter.m
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBIColorfulCell.h"
#import "CBISplitViewController.h"
#import "Router.h"
#import "UIViewController+Transitions.h"
#import "CBILog.h"

@implementation CBIColorfulViewModel (CellViewModel)

- (UITableViewCell *)tableViewController:(UITableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBIColorfulCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:@"CBIColorfulCell"];
    cell.viewModel = self;
    return cell;
}

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"didSelectRowAtIndexPath - %@ : model : %@", NSStringFromClass([self class]), NSStringFromClass([self.model class]));
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        controller.tableView.userInteractionEnabled = NO;
    }
    [[Router sharedRouter] routeFromController:controller toViewModel:self];
}

@end
