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
    
    

#import <TechDebt/MyLittleViewController.h>

typedef NSString *(^IdentityBlock)(id object);

@interface MLVCCollectionController (CBIRefresh)

- (RACTuple *)refreshCollectionWithModelSignal:(RACSignal *)modelSignal modelIDBlock:(IdentityBlock)modelIDBlock viewModelIDBlock:(IdentityBlock)viewModelIDBlock viewModelUpdateBlock:(void (^)(id<MLVCViewModel> existingViewModel, id model))viewModelUpdateBlock viewModelFactoryBlock:(id<MLVCViewModel> (^)(id model))factoryBlock;

@end
