//
//  CBIDropbox.m
//  iCanvas
//
//  Created by Miles Wright on 3/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIDropbox.h"
BOOL handleDropboxOpenURL(NSURL *url) {
    return [[DBChooser defaultChooser] handleOpenURL:url];
}

@implementation CBIDropbox

+ (void)chooseFileFromViewController:(UIViewController *)fromViewController completionBlock:(ChooseFileCompletionBlock)completionBlock cancelledBlock:(void (^)())cancelledBlock
{
    [CBIDropbox chooseFileWithLinkType:DBChooserLinkTypePreview fromViewController:fromViewController completionBlock:completionBlock cancelledBlock:cancelledBlock];
}

+ (void)chooseFileWithLinkType:(DBChooserLinkType)linkType fromViewController:(UIViewController *)fromViewController completionBlock:(ChooseFileCompletionBlock)completionBlock cancelledBlock:(void (^)())cancelledBlock
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
