//
//  CBIDropbox.h
//  iCanvas
//
//  Created by Miles Wright on 3/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DBChooser/DBChooser.h>

typedef void (^ChooseFileCompletionBlock)(NSArray *results);

extern BOOL handleDropboxOpenURL(NSURL *url);

@interface CBIDropbox : NSObject

+ (void)chooseFileFromViewController:(UIViewController *)fromViewController completionBlock:(ChooseFileCompletionBlock)completionBlock cancelledBlock:(void (^)())cancelledBlock;

+ (void)chooseFileWithLinkType:(DBChooserLinkType)linkType fromViewController:(UIViewController *)fromViewController completionBlock:(ChooseFileCompletionBlock)completionBlock cancelledBlock:(void (^)())cancelledBlock;

@end
