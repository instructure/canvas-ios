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
    
    

//
// CBIPeopleViewModel.m
// Created by Jason Larsen on 3/28/14.
//

#import "CBIPeopleViewModel.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBIColorfulCell.h"
#import "CKIClient+CBIClient.h"
@import CanvasKeymaster;
#import "UIImage+TechDebt.h"

@interface CBIPeopleViewModel ()

@end

@implementation CBIPeopleViewModel

@dynamic model;

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.name);
        [self setupAvatar];
    }
    return self;
}

- (void)setupAvatar
{
    UIImage *placeholderImage = [self userPlaceholderImage];
    self.icon = placeholderImage;

    [[self avatarDataSignal] subscribeNext:^(NSData *avatarImageData) {
        self.icon = [UIImage imageWithData:avatarImageData];;
    } error:^(NSError *error) {
        NSLog(@"Error fetching avatar for userID:%@, %@", self.model.id, error);
    }];
}

- (RACSignal *)avatarDataSignal
{
    CKIClient *client = [[CKIClient currentClient] imageClient];

    return [[RACObserve(self, model.avatarURL) filter:^BOOL(NSURL *avatarURL) {
            return avatarURL != nil;
    }] flattenMap:^__kindof RACStream *(NSURL *avatarURL) {
        return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            NSURLSessionDataTask *avatarTask = [client GET:avatarURL.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [subscriber sendError:error];
            }];

            return [RACDisposable disposableWithBlock:^{
                [avatarTask cancel];
            }];
        }];
    }];
}

- (UIImage *)userPlaceholderImage
{
    static UIImage *placeholderImage;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        placeholderImage = [[UIImage techDebtImageNamed:@"icon_user"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    });

    return placeholderImage;
}

- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBIColorfulCell *cell = (CBIColorfulCell *)[super tableViewController:controller cellForRowAtIndexPath:indexPath];

    cell.roundIcon = YES;

    [RACObserve(self, icon) subscribeNext:^(id x) {
        // the index path might have changed by the time we get in this block (because of insertions)
        // make sure we get the latestIndexPath
        NSIndexPath *latestIndexPath = [controller.tableView indexPathForCell:cell];
        if (latestIndexPath) {
            [controller.tableView reloadRowsAtIndexPaths:@[latestIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];

    return cell;
}


@end
