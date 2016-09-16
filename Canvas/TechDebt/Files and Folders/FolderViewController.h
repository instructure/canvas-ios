//
//  FolderViewController.h
//  iCanvas
//
//  Created by BJ Homer on 7/13/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
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
