//
//  CBIMessageNewMessageCell.h
//  iCanvas
//
//  Created by derrick on 12/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBIResizableTextView.h"
#import "MultiLineTextField.h"

@class CBIMessageComposeMessageViewModel;

@interface CBIMessageComposeMessageCell : UITableViewCell
@property (nonatomic) CBIMessageComposeMessageViewModel *viewModel;
@property (nonatomic) CGFloat height;
@end
