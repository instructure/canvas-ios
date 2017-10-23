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
    
    

#import <CanvasKit/CanvasKit.h>
#import "CBIViewModel.h"
#import <TechDebt/MyLittleViewController.h>

@interface CBIColorfulViewModel : CBIViewModel <MLVCTableViewModel>

+ (id (^)(id))modelMappingBlockObservingTintColor:(RACSignal *)tintColor;

@property (nonatomic) NSString *name;
@property (nonatomic) UIImage *icon;
@property (nonatomic) UIColor *tintColor;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) NSString *detail;
/**
 returns a signal of viewModel pages for this collection.
 */
@property (nonatomic, readonly) RACSignal *refreshViewModelsSignal;
@end
