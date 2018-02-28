//
//  UIAlertController+Show.h
//  CanvasKit
//
//  Created by Layne Moseley on 2/20/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Show)

- (void)show;
- (void)show:(void(^)(void))completion;

@end
