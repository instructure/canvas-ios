//
//  CKRemoteImageButton.h
//  CanvasKit
//
//  Created by Jason Larsen on 8/21/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKRemoteImageView;


typedef void(^CKRemoteImageButtonTappedBlock)();


@interface CKRemoteImageButton : UIButton

@property (nonatomic, strong) CKRemoteImageView *remoteImageView;
@property (nonatomic, copy) CKRemoteImageButtonTappedBlock tapBlock;
@property (nonatomic, weak) NSCache *imageCache;
@property (nonatomic, strong) NSURL *imageURL;

@end
