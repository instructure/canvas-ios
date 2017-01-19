//
//  CBIMultiUserTableViewController.m
//  iCanvas
//
//  Created by Brandon Pluim on 4/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
            [FXKeychain.sharedCanvasKeychain removeClient:client];
        }
    }];
    
    cell.profileImage.clipsToBounds = YES;
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height/2;
    [cell.profileImage setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"icon_profile" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
    
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
    [[FXKeychain sharedCanvasKeychain] removeClient:clientToDelete];
    [self reloadClients];
}

- (void)reloadClients {
    
    self.clients = [[[FXKeychain sharedCanvasKeychain] clients] sortedArrayUsingComparator:^NSComparisonResult(CKIClient *obj1, CKIClient *obj2) {
        return [obj1.currentUser.name compare:obj2.currentUser.name];
    }];
    [self.tableView reloadData];
}

@end
