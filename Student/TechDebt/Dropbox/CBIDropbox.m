//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

#import "CBIDropbox.h"
BOOL handleDropboxOpenURL(NSURL *url) {
    return [[DBChooser defaultChooser] handleOpenURL:url];
}

@implementation CBIDropbox

+ (void)chooseFileFromViewController:(UIViewController *)fromViewController completionBlock:(ChooseFileCompletionBlock)completionBlock cancelledBlock:(void (^)(void))cancelledBlock
{
    [CBIDropbox chooseFileWithLinkType:DBChooserLinkTypePreview fromViewController:fromViewController completionBlock:completionBlock cancelledBlock:cancelledBlock];
}

+ (void)chooseFileWithLinkType:(DBChooserLinkType)linkType fromViewController:(UIViewController *)fromViewController completionBlock:(ChooseFileCompletionBlock)completionBlock cancelledBlock:(void (^)(void))cancelledBlock
{
    [[DBChooser defaultChooser] openChooserForLinkType:linkType
                                    fromViewController:fromViewController completion:^(NSArray *results)
     {
         if ([results count]) {
             if (completionBlock) {
                 completionBlock(results);
             }
         } else {
             if (cancelledBlock) {
                 cancelledBlock();
             }
         }
     }];
}

@end
