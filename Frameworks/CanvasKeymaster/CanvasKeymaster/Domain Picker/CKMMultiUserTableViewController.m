//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CKMMultiUserTableViewController.h"

#import <CoreImage/CoreImage.h>
@import AFNetworking;
#import "FXKeychain+CKMKeychain.h"
#import "CKMMultiUserTableViewCell.h"
@import CanvasKit;

static NSString *const MULTI_USER_CELL_ID = @"MultiUserCell";
static NSString *const DELETE_EXTRA_CLIENTS_USER_PREFS_KEY = @"delete_extra_clients";

@interface CKMMultiUserTableViewController ()

@property (nonatomic, strong) RACSubject *userSelectionSubject;
@property (nonatomic, strong) NSArray *clients;

@end

@implementation CKMMultiUserTableViewController {
    RACSubject *_subjectForClient;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    _subjectForClient = [RACSubject new];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadClients];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.clients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKMMultiUserTableViewCell *cell = (CKMMultiUserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MULTI_USER_CELL_ID forIndexPath:indexPath];
    
    CKIClient *client = [self clientForIndexPath:indexPath];
    cell.usernameLabel.text = client.currentUser.name;
    cell.domainLabel.text = [client.baseURL description];
    
    RACSignal *fetchCurrentUserSignal = [client fetchCurrentUser];
    cell.client = client;

    __weak CKIClient *weakClient = client;
    [fetchCurrentUserSignal subscribeNext:^(CKIUser *currentUser) {
        [cell.client.currentUser mergeValuesForKeysFromModel:currentUser];
        [cell.profileImage setImageWithURL:cell.client.currentUser.avatarURL];
        [_subjectForClient sendNext:client];
    } error:^(NSError *error) {
        NSHTTPURLResponse *failingResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        if (failingResponse.statusCode == 401) {
            __strong CKIClient *client = weakClient;
            [[FXKeychain sharedKeychain] removeClient:client];
            [self reloadClients];
        }
    }];
    
    cell.profileImage.clipsToBounds = YES;
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height/2;
    UIImage *placeholder = [UIImage imageNamed:@"icon_profile" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    [cell.profileImage setImageWithURL:client.currentUser.avatarURL placeholderImage:placeholder];
    
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deleteClient:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKIClient *client = [self clientForIndexPath:indexPath];
    [self.userSelectionSubject sendNext:client];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

- (CKIClient *)clientForIndexPath:(NSIndexPath *)indexPath
{
    return self.clients[indexPath.row];
}

#pragma mark - Signal
- (RACSignal *)selectedUserSignal
{
    return self.userSelectionSubject;
}

#pragma mark - Subject

- (RACSubject *)userSelectionSubject
{
    if (!_userSelectionSubject) {
        _userSelectionSubject = [RACSubject subject];
    }
    return _userSelectionSubject;
}

- (void)deleteClient:(UIButton *)deleteBtn
{
    CKIClient *clientToDelete = self.clients[deleteBtn.tag];
    [[FXKeychain sharedKeychain] removeClient:clientToDelete];
    [self reloadClients];
}

- (void)prepareClients {
    self.clients = [[[FXKeychain sharedKeychain] clients] sortedArrayUsingComparator:^NSComparisonResult(CKIClient *obj1, CKIClient *obj2) {
        return [obj1.currentUser.name compare:obj2.currentUser.name];
    }];
    for (CKIClient *client in self.clients) {
        client.ignoreUnauthorizedErrors = YES;
    }
}

- (void)reloadClients {
    [self prepareClients];
    [self.tableView reloadData];
}

@end
