//
//  UISearchController+PSPDFKitAdditions.h
//  PSPDFKit
//
//  Copyright © 2015-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// Extends `UISearchController` with some helpers.
@interface UISearchController (PSPDFKitAdditions)

/// If the `searchResultsController` is a `UITableViewController` subclass, this returns its table view.
@property (nonatomic, readonly, nullable) UITableView *pspdf_searchResultsTableView;

/**
 Enables a workaround for rdar://352525 and rdar://32630657.

 rdar://352525: UISearchController: Status Bar on top of Search Bar after rotating
 http://www.openradar.me/352525
 
 rdar://32630657: UISearchController logs about loading view during deallocation due to uninstalling back gesture recognizer
 http://www.openradar.me/32630657
 */
- (void)pspdf_installWorkaroundsOn:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
