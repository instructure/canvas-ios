//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "QLPreviewManager.h"
#import <UIKit/UIKit.h>
#import <CanvasCore/CanvasCore-Swift.h>

@implementation QLPreviewManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(previewFile:(NSString *)url)
{
    self.fileURL = [[NSURL alloc] initWithString:url];
    UIViewController *view = [[HelmManager shared] topMostViewController];
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.delegate = self;
    preview.dataSource = self;
    [view presentViewController:preview animated:YES completion:nil];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

#pragma mark - QLPreviewControllerDelegate
- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id<QLPreviewItem>)item {
    return YES;
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.fileURL;
}

@end


