//
//  CSGGradingCommentsTableViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGGradingCommentsTableViewController.h"

#import "CSGAppDataSource.h"
#import "CSGGradingCommentCell.h"
#import "CSGMoviePlayerViewController.h"

#import "UITableViewController+CSGFetchedResultsController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

static NSString *const CSGGradingCommentsStudentTableViewCellID = @"CSGGradingCommentsStudentTableViewCellID";
static NSString *const CSGGradingCommentsCurrentUserTableViewCellID = @"CSGGradingCommentsCurrentUserTableViewCellID";
static NSString *const CSGGradingCommentsVideoTableViewCellID = @"CSGGradingCommentsVideoTableViewCellID";
static NSString *const CSGGradingCommentsVideoTableViewLeftCellID = @"CSGGradingCommentsVideoTableViewLeftCellID";
static NSString *const CSGGradingCommentsAudioTableViewCellID = @"CSGGradingCommentsAudioTableViewCellID";
static NSString *const CSGGradingCommentsAudioTableViewLeftCellID = @"CSGGradingCommentsAudioTableViewLeftCellID";

@interface CSGGradingCommentsTableViewController ()

@property (nonatomic, strong) CSGAppDataSource *dataSource;
@property (nonatomic, strong) CSGGradingCommentCell *sizingCell;

@property (nonatomic, strong) UIImage *leftFaceCommentBubble;
@property (nonatomic, strong) UIImage *rightFaceCommentBubble;
@property (nonatomic, strong) UILabel *noResultsLabel;
@property (nonatomic, strong) NSArray *sortedSubmissionComments;
@property (nonatomic, strong) MPMoviePlayerViewController *internalPlayerVC;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) NSInteger currentAudioPlayingRow;

@end

@implementation CSGGradingCommentsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.internalPlayerVC = [CSGMoviePlayerViewController sharedMoviePlayerViewController];
    self.dataSource = [CSGAppDataSource sharedInstance];
    self.tableView.backgroundColor = [UIColor csg_gradingCommentTableBackgroundColor];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    
    [self setupNoResultsLabel];
    @weakify(self);
    [RACObserve(self, dataSource.selectedSubmissionRecord) subscribeNext:^(CKISubmissionRecord *submissionRecord) {
        @strongify(self);
        
        self.sortedSubmissionComments = [submissionRecord.comments sortedArrayUsingComparator:^NSComparisonResult(CKISubmissionComment *comment1, CKISubmissionComment *comment2) {
            return [comment1.createdAt compare:comment2.createdAt];
        }];
        [self.tableView reloadData];
        
        self.noResultsLabel.hidden = [self.sortedSubmissionComments count];
    }];
    
    UIImage *commmentsBGLeft = [UIImage imageNamed:@"comments_bg_left"];
    self.leftFaceCommentBubble =[commmentsBGLeft resizableImageWithCapInsets:UIEdgeInsetsMake(40, 10, 5, 5)];
    
    UIImage *commmentsBGRight = [UIImage imageNamed:@"comments_bg_right"];
    self.rightFaceCommentBubble =[commmentsBGRight resizableImageWithCapInsets:UIEdgeInsetsMake(40, 5, 5, 10)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
    if (bottomOffset.y > 0) {
        [self.tableView setContentOffset:bottomOffset animated:NO];
    }
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNoResultsLabel
{
    self.noResultsLabel = [[UILabel alloc] initWithFrame:self.tableView.frame];
    self.noResultsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.noResultsLabel.numberOfLines = 0;
    self.noResultsLabel.backgroundColor = [UIColor clearColor];
    self.noResultsLabel.textColor = RGB(155, 155, 155);
    self.noResultsLabel.font = [UIFont systemFontOfSize:24.0];
    self.noResultsLabel.textAlignment = NSTextAlignmentCenter;
    self.noResultsLabel.text = NSLocalizedString(@"No comments for this submission", @"No Comments Description Text");
    self.tableView.backgroundView = self.noResultsLabel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sortedSubmissionComments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKISubmissionComment *submissionComment = self.sortedSubmissionComments[indexPath.row];
    
    CSGGradingCommentCell *cell = nil;
    
    NSString *identifier = CSGGradingCommentsCurrentUserTableViewCellID;
    
    if (submissionComment.mediaComment && [submissionComment.mediaComment.mediaType isEqualToString:@"video"]) {
        if ([submissionComment.authorID isEqualToString:TheKeymaster.currentClient.currentUser.id]) {
            identifier = CSGGradingCommentsVideoTableViewCellID;
        } else {
            identifier = CSGGradingCommentsVideoTableViewLeftCellID;
        }
    } else if (submissionComment.mediaComment && [submissionComment.mediaComment.mediaType isEqualToString:@"audio"]) {
        if ([submissionComment.authorID isEqualToString:TheKeymaster.currentClient.currentUser.id])
        {
            identifier = CSGGradingCommentsAudioTableViewCellID;
        } else {
            identifier = CSGGradingCommentsAudioTableViewLeftCellID;
        }
    } else {
        if ([submissionComment.authorID isEqualToString:TheKeymaster.currentClient.currentUser.id]) {
            identifier = CSGGradingCommentsCurrentUserTableViewCellID;
        } else {
            identifier = CSGGradingCommentsStudentTableViewCellID;
        }
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // pick correct cell for user and display comment bubble correct orientation
    if ([submissionComment.authorID isEqualToString:[[TheKeymaster currentClient] currentUser].id]) {
        cell.commentContainerImageView.image = self.rightFaceCommentBubble;
    }
    else {
        cell.commentContainerImageView.image = self.leftFaceCommentBubble;
    }
    
    BOOL mediaCommentsAreTheSame = [[cell.comment.mediaComment.url absoluteString] isEqualToString:[submissionComment.mediaComment.url absoluteString]];
    
    if (cell.comment.id != submissionComment.id && !mediaCommentsAreTheSame) {
        [cell setComment:submissionComment];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKISubmissionComment *submissionComment = self.sortedSubmissionComments[indexPath.row];
    if (submissionComment.mediaComment) {
        return 150;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
