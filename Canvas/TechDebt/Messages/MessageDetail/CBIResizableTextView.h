//
//  CBIResizableTextView.h
//  iCanvas
//
//  Created by derrick on 12/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;

@interface CBIResizableTextView : UITextView
@property (nonatomic, readonly) RACSignal *viewHeightSignal;
@end