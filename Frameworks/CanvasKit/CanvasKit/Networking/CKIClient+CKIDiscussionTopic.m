//
//  CKIClient+CKIDiscussionTopic.m
//  CanvasKit
//
//  Created by derrick on 12/13/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient+CKIDiscussionTopic.h"
#import "CKICourse.h"
#import "CKIDiscussionTopic.h"
@import ReactiveObjC;
#import "EXTScope.h"

@implementation CKIClient (CKIDiscussionTopic)

- (RACSignal *)fetchDiscussionTopicsForContext:(id<CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"discussion_topics"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIDiscussionTopic class] context:context];
}

- (RACSignal *)fetchDiscussionTopicForContext:(id<CKIContext>)context topicID:(NSString *)topicID
{
    NSString *path = [context.path stringByAppendingPathComponent:@"discussion_topics"];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat: @"%@", topicID]];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIDiscussionTopic class] context:context];
}

- (RACSignal *)fetchAnnouncementsForContext:(id<CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"discussion_topics"];
    
    NSDictionary *params = @{@"only_announcements":@"true"};
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKIDiscussionTopic class] context:context];
}


- (RACSignal *)markTopicAsRead:(CKIDiscussionTopic *)topic {
    NSParameterAssert(topic);
    
    NSString *path = [topic.path stringByAppendingPathComponent:@"read"];
    
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (self) {
            NSURLSessionDataTask *task = [self PUT:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                [subscriber sendCompleted];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [subscriber sendError:error];
            }];
            
            return [RACDisposable disposableWithBlock:^{
                [task cancel];
            }];
        }
        [subscriber sendError:[NSError errorWithDomain:@"com.instructure.icanvas" code:topic.id.integerValue userInfo:@{NSLocalizedDescriptionKey: @"The client died before you got around to marking this topic \"read\""}]];
        
        return [RACDisposable disposableWithBlock:^{
            // empty on purpose yo
        }];
    }];
}
@end
