//
//  DocumentLibraryView.h
//  iCanvas
//
//  Created by BJ Homer on 4/4/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DocumentLibraryViewDelegate;

@interface DocumentLibraryView : UIView
@property (weak) id <DocumentLibraryViewDelegate> delegate;
@property (strong, nonatomic) NSArray *itemURLs;
@property (strong, readonly) NSURL *frontItem;
@property (strong, readonly) NSArray *selectedItems;

@property (strong) NSString *noItemsHelpString;

- (void)setSelected:(BOOL)selected forItem:(NSURL *)item;
- (BOOL)itemIsSelected:(NSURL *)item;

- (void)removeItem:(NSURL *)item;
- (void)addItem:(NSURL *)item;
@end


@protocol DocumentLibraryViewDelegate <NSObject>
- (BOOL)libraryViewShouldShowHelpString:(DocumentLibraryView *)libraryView;
- (void)libraryView:(DocumentLibraryView *)libraryView didChangeFrontItem:(NSURL *)item;
- (void)libraryView:(DocumentLibraryView *)libraryView didTapFrontItem:(NSURL *)item;
- (UIViewController *)libraryViewControllerForPresentingFullScreenPreview:(DocumentLibraryView *)libraryView;

@end
