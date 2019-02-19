//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
