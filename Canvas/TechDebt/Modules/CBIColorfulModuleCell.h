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
    
    

#import "CBIColorfulCell.h"

typedef NS_ENUM(NSInteger, CBIColorfulModuleViewModelState) {
    CBIColorfulModuleViewModelStateNone,
    CBIColorfulModuleViewModelStateLocked,
    CBIColorfulModuleViewModelStateUnlocked,
    CBIColorfulModuleViewModelStateIncomplete,
    CBIColorfulModuleViewModelStateCompleted
};

@protocol CBIColorfulModuleViewModel <NSObject>
@property (nonatomic) BOOL lockedOut;
@property (nonatomic) CBIColorfulModuleViewModelState state;
@property (nonatomic) BOOL selected;
@end

@interface CBIColorfulModuleCell : CBIColorfulCell
@property (nonatomic) CBIColorfulViewModel<CBIColorfulModuleViewModel> *viewModel;
@end
