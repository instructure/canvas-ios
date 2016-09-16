//
//  CBIViewModel.h
//  iCanvas
//
//  Created by nlambson on 11/21/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <CanvasKit/CanvasKit.h>
@import MyLittleViewController;

@interface CBIViewModel : NSObject <MLVCViewModel>
+ (instancetype)viewModelForModel:(CKIModel *)model;
+ (id (^)(CKIConversation *))modelMappingBlock;

@property (nonatomic) NSString *viewControllerTitle;
@property (nonatomic) CKIModel *model;


@end
