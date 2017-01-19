//
//  CBIMultiUserTableViewCell.h
//  iCanvas
//
//  Created by Brandon Pluim on 4/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CanvasKit;

@interface CKMMultiUserTableViewCell : UITableViewCell

@property (nonatomic, strong) CKIClient *client;
@property (nonatomic, strong) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel *domainLabel;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

@end
