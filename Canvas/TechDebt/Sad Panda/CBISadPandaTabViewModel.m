//
//  CBISadPandaTabViewModel.m
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBISadPandaTabViewModel.h"
#import "UnsupportedViewController.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "UIViewController+Transitions.h"
#import "CBILog.h"

@implementation CBISadPandaTabViewModel
- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"selectedUnsupportedViewController : %@", self.name);
    UnsupportedViewController *un = [UnsupportedViewController new];
    un.tabName = self.name;
    un.canvasURL = self.model.htmlURL;
    
    [controller cbi_transitionToViewController:un animated:YES];
}
@end
