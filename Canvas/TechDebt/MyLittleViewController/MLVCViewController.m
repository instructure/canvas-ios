//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "MLVCViewController.h"

@implementation MLVCViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    RAC(self, title) = RACObserve(self, viewModel.viewControllerTitle);
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        RAC(self, title) = RACObserve(self, viewModel.viewControllerTitle);
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
        [self.viewModel viewControllerViewDidLoad:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillAppear:)]) {
        [self.viewModel viewController:self viewWillAppear:animated];
    }
    
    if ([self.viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        [self.viewModel refreshViewModelSignalForced:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillDisappear:)]) {
        [self.viewModel viewController:self viewWillDisappear:animated];
    }
}

- (void)setViewModel:(id<MLVCViewModel>)viewModel
{
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;

    if (self.isViewLoaded && [_viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
        [_viewModel viewControllerViewDidLoad:self];
    }
}

@end
