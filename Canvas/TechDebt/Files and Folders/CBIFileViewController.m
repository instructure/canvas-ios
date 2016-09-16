//
//  CBIFileViewController.m
//  iCanvas
//
//  Created by Rick Roberts on 3/28/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIFileViewController.h"

#import "RatingsController.h"
#import <CanvasKit1/CanvasKit1.h>
#import "CKCanvasAPI+CurrentAPI.h"

@implementation CBIFileViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, fileIdent) = [RACObserve(self, viewModel.model.id)  map:^(NSString *modelID) {
            return @([modelID longLongValue]);
        }];
        
        if ([self.viewModel.model.context isKindOfClass:[CKIGroup class]]) {
            CKIGroup *group = (CKIGroup *)self.viewModel.model.context;
            RAC(self, contextInfo) = [RACObserve(group, id) map:^id(NSString *value) {
                return [CKContextInfo contextInfoFromGroupIdent:[value longLongValue]];
            }];
        } else if ([self.viewModel.model.context isKindOfClass:[CKICourse class]]) {
            CKICourse *course = (CKICourse *)self.viewModel.model.context;
            RAC(self, contextInfo) = [RACObserve(course, id) map:^id(NSString *value) {
                return [CKContextInfo contextInfoFromCourseIdent:[value longLongValue]];
            }];
        }
        
        self.canvasAPI = CKCanvasAPI.currentAPI;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [RatingsController appLoadedOnViewController:self];
}

@end
