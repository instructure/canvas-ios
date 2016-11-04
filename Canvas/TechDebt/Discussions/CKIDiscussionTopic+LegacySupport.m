
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
    
    

#import "CKIDiscussionTopic+LegacySupport.h"
#import <CanvasKit1/CanvasKit1.h>

@implementation CKIDiscussionTopic (LegacySupport)
+ (instancetype)discussionTopicFromLegacyDiscussionTopic:(CKDiscussionTopic *)topic
{
    CKIDiscussionTopic *newOne;
    if (topic.contextInfo.contextType == CKContextTypeGroup){
        CKIGroup * group = [CKIGroup modelWithID:[@(topic.contextInfo.ident) description]];
        newOne = [CKIDiscussionTopic modelWithID:[@(topic.ident) description] context:group];
    } else {
        CKICourse * course = [CKICourse modelWithID:[@(topic.contextInfo.ident) description]];
        newOne = [CKIDiscussionTopic modelWithID:[@(topic.ident) description] context:course];
    }
    
    newOne.messageHTML = topic.message;
    newOne.title = topic.title;
    newOne.postedAt = topic.postDate;
    newOne.lastReplyAt = topic.lastReplyDate;
    
    // only adding a few for right now pretty confident that's all that is needed.
    return newOne;
}
@end
