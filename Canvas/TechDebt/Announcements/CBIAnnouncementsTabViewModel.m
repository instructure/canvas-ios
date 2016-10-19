//
//  CBIAnnouncementsTabViewModel.m
//  iCanvas
//
//  Created by nlambson on 1/2/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIAnnouncementsTabViewModel.h"
#import "CBIAnnouncementViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "Router.h"
#import "CreateDiscussionViewController.h"
#import "EXTScope.h"
#import "AnnouncementCreationIPhoneStrategy.h"
#import "CKIDiscussionTopic+LegacySupport.h"
@import CanvasKeymaster;
#import "UIImage+TechDebt.h"

@implementation CBIAnnouncementsTabViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.discussionCreationStrategy = [AnnouncementCreationIPhoneStrategy new];
        self.discussionViewModelClass = [CBIAnnouncementViewModel class];
        self.createButtonImage = [UIImage techDebtImageNamed:@"icon_announcements"];
        self.viewControllerTitle = NSLocalizedString(@"Announcements", @"Title for the announcements view controller");
        
        self.canCreateSignal = [RACObserve(self, model.context) map:^id(id<CKIContext> context) {
            if ([context isKindOfClass:[CKICourse class]]) {
                
                CKICourse *course = (CKICourse *)context;
                
                if (course.enrollments == nil || course.enrollments.count == 0 || course.name.length == 0) {
                    [[TheKeymaster.currentClient refreshModel:course parameters:nil] subscribeCompleted:^{
                        self.model.context = course;
                    }];
                }
                
                NSArray *enrollmentTypes = [course.enrollments.rac_sequence map:^id(id value) {
                    
                    return [value valueForKey:@"type"];
                }].array;
                
                __block BOOL isTeacher = NO;
                [enrollmentTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([[NSNumber numberWithInt:CKIEnrollmentTypeTeacher] isEqualToNumber:obj]) {
                        isTeacher = YES;
                        *stop = YES;
                        return;
                    }
                }];
                
                return @(isTeacher);
            }
            return @(YES);
        }];
    }
    return self;
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [super tableViewControllerViewDidLoad:tableViewController];
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIColorfulSubtitleCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIColorfulCell"];
    tableViewController.tableView.rowHeight = 50;
    tableViewController.tableView.separatorInset = UIEdgeInsetsMake(0, 20.f, 0, 0);

}

- (RACSignal *)refreshModelSignal
{
    return [[CKIClient currentClient] fetchAnnouncementsForContext:self.model.context];
}

@end
