//
//  VideoRecorderController.h
//  iCanvas
//
//  Created by BJ Homer on 4/24/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoRecorderController : UIImagePickerController

- (id)initWithSourceType:(UIImagePickerControllerSourceType)type Handler:(void (^)(NSURL *movieURL))handler;

@end
