//
//  CKRemoteImageView.h
//  CanvasKit
//
//  Created by BJ Homer on 6/8/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKRemoteImageView : UIImageView

@property (weak) NSCache *imageCache; // required!
@property (nonatomic, copy) NSURL *imageURL;
@property (copy) void (^afterLoadingBlock) ();

- (void)reloadImage;

@end
