//
//  ReceivedFilesViewController.h
//  iCanvas
//
//  Created by BJ Homer on 4/2/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceivedFilesViewController : UIViewController
- (id)init;

+ (BOOL)addToReceivedFiles:(NSURL *)url error:(NSError **)error;

@property (strong) void(^onSubmitBlock)(NSArray *urls);
@property (copy, nonatomic) NSString *submitButtonTitle;

@end
