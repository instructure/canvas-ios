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
    
    

#import "CBISyllabusViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "EXTScope.h"
#import "UIImage+TechDebt.h"
#import "CKCourse.h"

@implementation CBISyllabusViewModel
- (UIImage *)imageForTypeName:(NSString *)typeString
{
    return [[UIImage techDebtImageNamed:@"icon_syllabus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Syllabus", @"Title for Syllabus screen");
        self.icon = [self imageForTypeName:nil];
        self.syllabusDate = [NSDate date];
        self.viewControllerTitle = self.name;
    }
    return self;
}

+ (NSString *)syllabusHTMLFromCourse:(CKCourse *)course {
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSBundle *canvasFrameworkBundle = [NSBundle bundleForClass:[CKCourse class]];
    
    NSURL *cssURL = [bundle URLForResource:@"ScheduleItemDetails" withExtension:@"css"];
    NSURL *jsURL = [bundle URLForResource:@"ScheduleItemDetails" withExtension:@"js"];
    NSURL *rewriteLinkURL = [canvasFrameworkBundle URLForResource:@"rewrite-api-links" withExtension:@"js"];
    NSURL *templateURL = [bundle URLForResource:@"SyllabusDetails" withExtension:@"html"];
    
    NSString *css = [NSString stringWithContentsOfURL:cssURL encoding:NSUTF8StringEncoding error:nil];
    NSString *js = [NSString stringWithContentsOfURL:jsURL encoding:NSUTF8StringEncoding error:nil];
    NSString *rewriteJS = [NSString stringWithContentsOfURL:rewriteLinkURL encoding:NSUTF8StringEncoding error:nil];
    NSString *htmlTemplate = [NSString stringWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:nil];
    
    NSString *scrubbedHTML = [htmlTemplate stringByReplacingOccurrencesOfString:@"{$TITLE$}" withString:course.name ?: @""];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$COURSE_CODE$}" withString:course.courseCode ?: @""];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$CONTENT$}" withString:course.syllabusBody ?: @""];
    
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$CSS$}" withString:css ?: @""];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$JS$}" withString:js ?: @""];
    scrubbedHTML = [scrubbedHTML stringByReplacingOccurrencesOfString:@"{$REWRITE_API_LINKS$}" withString:rewriteJS ?: @""];
    
    return scrubbedHTML;
}

@end
