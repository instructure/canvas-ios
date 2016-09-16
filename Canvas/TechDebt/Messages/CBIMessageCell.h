//
//  CBIMessageCell.h
//  iCanvas
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBIMessageViewModel;

@interface CBIMessageCell : UITableViewCell
@property (nonatomic, strong) CBIMessageViewModel *viewModel;
@end
