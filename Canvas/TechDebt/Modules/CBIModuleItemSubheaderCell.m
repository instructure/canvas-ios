//
//  CBIModuleItemSubheaderCell.m
//  iCanvas
//
//  Created by derrick on 2/19/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIModuleItemSubheaderCell.h"
#import "CBIModuleItemViewModel.h"


@interface CBIModuleItemSubheaderCell ()
@end

@implementation CBIModuleItemSubheaderCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    RAC(self, textLabel.text) = RACObserve(self, viewModel.model.title);
}

@end
