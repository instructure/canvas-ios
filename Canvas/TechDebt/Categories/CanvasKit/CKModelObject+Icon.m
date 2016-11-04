
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
