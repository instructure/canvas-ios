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
    
    

#import "PagedItemsViewController.h"
@class CKFolder;
@class CKCanvasAPI;

typedef enum {
    FolderInterfaceStyleLight,
    FolderInterfaceStyleDark
} FolderInterfaceStyle;

@interface FolderViewController : PagedItemsViewController

- (id)initWithInterfaceStyle:(FolderInterfaceStyle)style;
- (id)init UNAVAILABLE_ATTRIBUTE;

@property (strong) CKCanvasAPI *canvasAPI;
@property (nonatomic, strong) CKFolder *folder;

@property (assign) BOOL preservesSelection;

@property FolderInterfaceStyle interfaceStyle;

// If not set, the file will be pushed on a navigation stack
@property (copy) void (^fileSelectionBlock)(CKAttachment *file);

- (void)deselectCurrentSelection;
- (void)loadRootFolderForContext:(CKContextInfo *)context;

@end
