//
//  CKModelObject+Icon.h
//  iCanvas
//
//  Created by derrick on 5/23/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKModelObject+Icon.h"
#import <CanvasKit1/CanvasKit1.h>
#import "UIImage+TechDebt.h"

@interface CKModelObject (IconInternal)
- (NSString *)specificImageName;
@end

@implementation CKModelObject (Icon)

- (NSString *)specificImageName
{
    return nil;
}

- (UIImage *)whiteIcon
{
    return [UIImage techDebtImageNamed:[NSString stringWithFormat:@"icon_%@_white.png", [self specificImageName]]];
}

- (UIImage *)icon
{
    return [UIImage techDebtImageNamed:[NSString stringWithFormat:@"icon_%@.png", [self specificImageName]]];
}

@end

@implementation CKCalendarItem (Icon)
- (NSString *)specificImageName
{
    return @"calendar";
}

@end


@implementation CKAssignment (Icon)
- (NSString *)specificImageName
{
    NSString *filename;
    switch (self.type) {
        case CKAssignmentTypeQuiz:
            filename = @"quizzes";
            break;
        case CKAssignmentTypeDiscussion:
            filename = @"discussions";
            break;
        default:
            filename = @"assignments";
            break;
    }
    return filename;
}
@end

@implementation CKSubmissionAttempt (Icon)

- (NSString *)specificImageName
{
    switch (self.type) {
        case CKSubmissionTypeDiscussionTopic:
            return @"discussions";
        case CKSubmissionTypeMediaRecording:
            return @"media";
        case CKSubmissionTypeOnlineQuiz:
            return @"quizzes";
        case CKSubmissionTypeOnlineTextEntry:
            return @"textsubmission";
        case CKSubmissionTypeOnlineURL:
            return @"link";
        case CKSubmissionTypeOnlineUpload:
        default:
            return @"document";
    }
}

@end


#define SPECIFIC_IMAGE_NAME_FOR_CLASS(klass, name) \
@implementation klass (ImageFactory) \
- (NSString *)specificImageName { \
    return name ; \
} \
@end

SPECIFIC_IMAGE_NAME_FOR_CLASS(CKPage, @"pages");
SPECIFIC_IMAGE_NAME_FOR_CLASS(CKDiscussionTopic, @"discussions");
