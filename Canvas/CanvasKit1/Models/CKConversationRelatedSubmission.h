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
    
    

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

//{
//    "assignment" : {   
//      "anonymous_submissions" : true,
//      "course_id" : 23654,
//      "description" : "<p>I don't care who you are. Just answer the questions.</p>",
//      "due_at" : "2011-05-31T23:59:00-06:00",
//      "grading_type" : "points",
//      "id" : 73976,
//      "muted" : false,
//      "name" : "Anonymous Survey",
//      "points_possible" : 10,
//      "position" : 1,
//      "submission_types" : [ "online_quiz" ]
//    },
//    "assignment_id" : 73976,
//    "attempt" : 1,
//    "body" : "user: 243017, quiz: 32909, score: 10, time: Wed May 04 22:27:51 +0000 2011",
//    "grade" : "10",
//    "grade_matches_current_submission" : true,
//    "preview_url" : "https://canvas.beta.instructure.com/courses/73976/assignments/243017/submissions/129534?preview=1",
//    "score" : 10,
//    "submission_comments" : [ { "author_id" : 242527,
//        "author_name" : "Mark",
//        "comment" : "I know who you are.",
//        "created_at" : "2011-10-24T14:19:53-06:00"
//    } ],
//    "submission_type" : "online_quiz",
//    "submitted_at" : "2011-05-04T16:27:51-06:00",
//    "url" : null,
//    "user_id" : 243017
//}

@class CKAssignment;

@interface CKConversationRelatedSubmission : CKModelObject

@property (assign) uint64_t assignmentIdent;
@property (assign) uint64_t userIdent;
@property (strong) CKAssignment *assignment;
@property (copy) NSDate *submittedAt;
@property (copy) NSString *grade;
@property (assign) int score;
@property (copy) NSArray *recentComments;

- (id)initWithInfo:(NSDictionary *)info;

@end
