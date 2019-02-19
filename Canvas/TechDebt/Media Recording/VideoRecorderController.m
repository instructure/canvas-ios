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
    
    

#import "VideoRecorderController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "iCanvasConstants.h"

@interface VideoRecorderController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation VideoRecorderController {
    void (^videoHandler)(NSURL *movieURL);
}

- (id)initWithSourceType:(UIImagePickerControllerSourceType)type Handler:(void (^)(NSURL *movieURL))handler {
    self = [super init];
    if (self) {
        videoHandler = handler;
        
        self.delegate = self;
        self.sourceType = type;
        self.mediaTypes = @[(__bridge NSString *) kUTTypeMovie];

    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    videoHandler(info[UIImagePickerControllerMediaURL]);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
