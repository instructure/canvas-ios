//
//  UISearchController+PSPDFKitAdditions.h
//  PSPDFKit
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@interface UISearchController (PSPDFKitAdditions)

/// If the `searchResultsController` is a `UITableViewController` subclass, this returns its table view.
@property (nonatomic, readonly, nullable) UITableView *pspdf_searchResultsTableView;

/// Enables a workaround for rdar://352525.
/// UISearchController: Status Bar on top of Search Bar after rotating
/// http://openradar.appspot.com/radar?id=5542248011792384
- (void)pspdf_install352525StatusBarWorkaroundOn:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
