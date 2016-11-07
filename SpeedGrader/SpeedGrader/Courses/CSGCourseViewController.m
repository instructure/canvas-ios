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
// CSGCourseViewController.m
// Created by Jason Larsen on 4/29/14.
//

#import "CSGCourseViewController.h"

#import "CSGCourseCell.h"
#import "CSGAssignmentGroupTableViewController.h"
#import "CSGBadgeView.h"
#import "CSGColorManager.h"
#import "UICollectionViewController+CSGFetchedResultsController.h"
#import "CSGFlyingPandaRefreshControl.h"
#import "CSGNoResultsView.h"
#import "RatingsController.h"
#import "CSGAppDataSource.h"

@import Masonry;

static NSString *const CSGCourseViewControllerCoursesHaveFetched = @"CSGCourseViewControllerCoursesHaveFetched";
static NSString *const CSGCourseCellID = @"CSGCourseCell";

typedef NS_ENUM(NSInteger, CSGCourseCollectionView) {
    CSGCourseCollectionViewFavorites = 0,
    CSGCourseCollectionViewAllCourses = 1
};

@interface CSGCourseViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) CSGAppDataSource *dataSource;

// UI Elements
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) CSGFlyingPandaRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *courses;

@property (nonatomic, strong) CSGNoResultsView *noResultsView;

// Instance Vars
@property (nonatomic, strong) NSString *noFavoritesString;
@property (nonatomic, strong) NSString *noCoursesString;
@property (nonatomic) BOOL reloadingData;

@end

@implementation CSGCourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    [self setupView];
    [self.refreshControl startLoading];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [RatingsController appLoadedOnViewController:self];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadDataFromDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.courses count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSGCourseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CSGCourseCellID forIndexPath:indexPath];
    CKICourse *course = self.courses[indexPath.row];
    cell.course = course;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogInfo(@"INDEX SELECTED: %@", indexPath);
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    CKICourse *course = self.courses[indexPath.row];
    [[CSGAppDataSource sharedInstance] setCourse:course];
    [self pushAssignmentsForCourse:course];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsPortrait(orientation)) {
        return CGSizeMake(300.0f, 240.0f);
    } else if(UIInterfaceOrientationIsLandscape(orientation)){
        return CGSizeMake(276.0f, 221.0f);
    }
    
    return CGSizeMake(300.0f, 240.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsPortrait(orientation)) {
        return UIEdgeInsetsMake(50.0f, 58.0f, 50.0f, 58.0f);
    } else if(UIInterfaceOrientationIsLandscape(orientation)){
        return UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);
    }
    
    return UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 50.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshControl scrollViewDidEndDragging];
}

#pragma mark - Orientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - SetupView

- (void)setupView {
    self.collectionView.backgroundColor = [UIColor csg_offWhite];
    
    // Setup Pull To Refresh
    self.refreshControl = [[CSGFlyingPandaRefreshControl alloc] initWithScrollView:self.collectionView target:self action:@selector(reloadData:)];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    [self setupNoResults];
    
    [self setupRACBindings];
}

- (void)setupNoResults {
    self.noResultsView = [CSGNoResultsView instantiateFromXib];
    self.noResultsView.alpha = 0.0;
    self.noResultsView.imageView.image = [UIImage imageNamed:@"panda_superman"];
    self.noResultsView.tintColor = [UIColor lightGrayColor];
    self.collectionView.backgroundView = self.noResultsView;
    
    self.noFavoritesString = NSLocalizedString(@"SuperPanda found no courses for you to grade.", @"No Favorites Text");
    self.noCoursesString = NSLocalizedString(@"SuperPanda found no courses for you to grade.", @"No Courses Text");
}

- (void)setupRACBindings {
    @weakify(self);
    [RACObserve(self, showFavorites) subscribeNext:^(id x) {
        @strongify(self);
        self.noResultsView.commentLabel.text = self.showFavorites ? self.noFavoritesString : self.noCoursesString;
    }];
}

#pragma mark - UI Actions

- (void)setShowFavorites:(BOOL)showFavorites {
    _showFavorites = showFavorites;
    
    DDLogInfo(@"SET SHOW FAVORITES: %@", showFavorites ? @"YES":@"NO");
    if (!self.reloadingData) {
        [self reloadDataFromDataSource];
        [self showNoResults:self.courses.count];
    }
}

- (void)showNoResults:(BOOL)results {
    [UIView animateWithDuration:0.25 animations:^{
        self.noResultsView.alpha = !results;
    }];
}

#pragma mark - Data Fetching

- (void)reloadData:(CSGFlyingPandaRefreshControl *)refreshControl {
    self.reloadingData = YES;
    [self showNoResults:YES];
    DDLogInfo(@"REFRESH COURSE DATA");
    
    CSGColorManager *colorManager = [CSGColorManager new];
    [colorManager fetchColorDataForUserWithSuccess:^{
        [self.dataSource reloadCoursesWithSuccess:^{
            [self.refreshControl finishLoading];
            
            self.reloadingData = NO;
            [self reloadDataFromDataSource];
            [self showNoResults:self.courses.count];
        } failure:^(NSError *error) {
            // TODO: display errors
            self.reloadingData = NO;
            [self.refreshControl finishLoading];
            [self showNoResults:NO];
        }];
    } failure:^{
        // TODO: display errors
        self.reloadingData = NO;
        [self.refreshControl finishLoading];
        [self showNoResults:NO];
    }];
}

- (void)reloadDataFromDataSource {
    self.courses = self.showFavorites ? self.dataSource.favoriteCourses : self.dataSource.courses;
    [self.collectionView reloadData];
}

#pragma mark - Transitions

- (void)pushAssignmentsForCourse:(CKICourse *)course {
    DDLogInfo(@"COURSE SELECTED: %@ - %@ (%@)", course.name, course.id, course.courseCode);
    
    CSGAssignmentGroupTableViewController *assignmentViewController = [CSGAssignmentGroupTableViewController instantiateFromStoryboard];
    [self.navigationController pushViewController:assignmentViewController animated:YES];
}

@end
