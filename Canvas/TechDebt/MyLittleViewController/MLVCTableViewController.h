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
    
    

#import <UIKit/UIKit.h>
#import "MLVCTableViewModel.h"
@class RACSignal;

@interface MLVCTableViewController : UITableViewController
@property (nonatomic) IBOutlet id<MLVCTableViewModel> viewModel;

@property (nonatomic, readonly) RACSignal *selectedCellViewModelSignal;
@property (nonatomic, readonly) RACSignal *tableViewDidAppearSignal;
@property (nonatomic, strong) id customRefreshControl;
@property (nonatomic, strong) NSString *url;

- (void)refreshFromRefreshControl:(id)refreshControl;
@end
