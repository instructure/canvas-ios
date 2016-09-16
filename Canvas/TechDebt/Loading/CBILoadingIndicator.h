//
//  CBILoadingIndicator.h
//  iCanvas
//
//  Created by rroberts on 11/21/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CBILoadingIndicator : NSObject

@property (nonatomic, strong) NSArray *colors;

- (id)initWithViewController:(UIViewController *)controller colorArray:(NSArray *)colors;
- (void)showLoadingBar;
- (void)hideLoadingBar;

+ (CBILoadingIndicator*)indicatorForNavigationBar:(UINavigationBar *)navigationBar;
- (void)showNavigationBarLoadingIndicator;
- (void)hideNavigationBarLoadingIndicator;

@end
