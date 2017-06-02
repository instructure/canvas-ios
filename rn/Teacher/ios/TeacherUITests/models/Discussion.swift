/*
 * Copyright (C) 2017 - present Instructure, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/* This is an auto-generated file. */

struct Discussion {
    static let sideComment = "side_comment"
    static let threaded = "threaded"

    let id: Int
    let title: String
    let lastReplyAt: String
    let delayedPostAt: String
    let postedAt: String
    let assignmentId: Int
    let rootTopicId: Int
    let position: Int
    let podcastHasStudentPosts: Bool
    let discussionType: String
    let lockAt: String
    let allowRating: Bool
    let onlyGradersCanRate: Bool
    let sortByRating: Bool
    let userName: String
    let discussionSubentryCount: Int
    // TODO: permissions
    let requireInitialPost: Bool
    let userCanSeePosts: Bool
    let podcastUrl: String
    let readState: String
    let unreadCount: Int
    let subscribed: Bool
    // TODO: topicChildren, attachments
    let published: Bool
    let canUnpublish: Bool
    let locked: Bool
    let canLock: Bool
    let commentsDisabled: Bool
    let authorId: String
    let authorDisplayName: String
    let htmlUrl: String
    let pinned: Bool
    let groupCategoryId: Int
    let canGroup: Bool
    let lockedForUser: Bool
    let message: String
    let isAnnouncement: Bool
}
