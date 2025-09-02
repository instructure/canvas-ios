//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Core
import Foundation

public struct CreateDSDiscussionWithCheckpointsRequest: APIGraphQLRequestable {
    public typealias Response = CreateDSDiscussionWithCheckpointsResponse
    public typealias RequestBody = CreateDSDiscussionWithCheckpointsRequestBody

    public let variables: Variables

    public init(body: RequestBody) {
        self.variables = Variables(
            contextId: body.contextId,
            contextType: .course,
            title: body.title,
            message: body.message,
            published: body.published,
            assignment: body.assignment,
            checkpoints: body.checkpoints
        )
    }

    public static let operationName = "CreateDiscussionTopic"
    // swiftlint:disable line_length
    public static let query = """
        mutation \(operationName)($contextId: ID!, $contextType: DiscussionTopicContextType!, $title: String, $message: String, $published: Boolean, $requireInitialPost: Boolean, $anonymousState: DiscussionTopicAnonymousStateType, $delayedPostAt: DateTime, $lockAt: DateTime, $isAnonymousAuthor: Boolean, $allowRating: Boolean, $onlyGradersCanRate: Boolean, $onlyVisibleToOverrides: Boolean, $todoDate: DateTime, $podcastEnabled: Boolean, $podcastHasStudentPosts: Boolean, $locked: Boolean, $expanded: Boolean, $expandedLocked: Boolean, $sortOrder: DiscussionSortOrderType, $sortOrderLocked: Boolean, $discussionType: DiscussionTopicDiscussionType, $isAnnouncement: Boolean, $specificSections: String, $groupCategoryId: ID, $assignment: AssignmentCreate, $checkpoints: [DiscussionCheckpoints!], $fileId: ID, $ungradedDiscussionOverrides: [AssignmentOverrideCreateOrUpdate!]) {
          createDiscussionTopic(
            input: {contextId: $contextId, contextType: $contextType, title: $title, message: $message, published: $published, requireInitialPost: $requireInitialPost, anonymousState: $anonymousState, delayedPostAt: $delayedPostAt, lockAt: $lockAt, discussionType: $discussionType, isAnonymousAuthor: $isAnonymousAuthor, allowRating: $allowRating, onlyGradersCanRate: $onlyGradersCanRate, onlyVisibleToOverrides: $onlyVisibleToOverrides, todoDate: $todoDate, podcastEnabled: $podcastEnabled, podcastHasStudentPosts: $podcastHasStudentPosts, locked: $locked, expanded: $expanded, expandedLocked: $expandedLocked, sortOrder: $sortOrder, sortOrderLocked: $sortOrderLocked, isAnnouncement: $isAnnouncement, specificSections: $specificSections, groupCategoryId: $groupCategoryId, assignment: $assignment, checkpoints: $checkpoints, fileId: $fileId, ungradedDiscussionOverrides: $ungradedDiscussionOverrides}
          ) {
            discussionTopic {
              _id
              contextType
              title
              message
              published
              requireInitialPost
              anonymousState
              delayedPostAt
              lockAt
              discussionType
              isAnonymousAuthor
              allowRating
              onlyGradersCanRate
              onlyVisibleToOverrides
              todoDate
              podcastEnabled
              podcastHasStudentPosts
              isAnnouncement
              replyToEntryRequiredCount
              expanded
              expandedLocked
              sortOrder
              sortOrderLocked
              assignment {
                _id
                name
                pointsPossible
                gradingType
                importantDates
                assignmentGroupId
                canDuplicate
                canUnpublish
                courseId
                description
                dueAt
                groupCategoryId
                id
                published
                restrictQuantitativeData
                sisId
                state
                suppressAssignment
                peerReviews {
                  automaticReviews
                  count
                  dueAt
                  enabled
                  __typename
                }
                checkpoints {
                  dueAt
                  name
                  onlyVisibleToOverrides
                  pointsPossible
                  tag
                  __typename
                }
                gradingStandard {
                  _id
                  __typename
                }
                __typename
              }
              attachment {
                ...Attachment
                __typename
              }
              __typename
            }
            errors {
              ...Error
              __typename
            }
            __typename
          }
        }

        fragment Attachment on File {
          id
          _id
          displayName
          url
          usageRights {
            ...UsageRights
            __typename
          }
          __typename
        }

        fragment UsageRights on UsageRights {
          id
          legalCopyright
          license
          useJustification
          _id
          __typename
        }

        fragment Error on ValidationError {
          attribute
          message
          __typename
        }
        """
    // swiftlint:enable line_length

    public struct Variables: Codable, Equatable {
        let contextId: String
        let contextType: RequestBody.DiscussionTopicContextType
        let title: String
        let message: String?
        let published: Bool
        let requireInitialPost: Bool?
        let anonymousState: RequestBody.DiscussionTopicAnonymousStateType?
        let delayedPostAt: String?
        let lockAt: String?
        let isAnonymousAuthor: Bool?
        let allowRating: Bool?
        let onlyGradersCanRate: Bool?
        let onlyVisibleToOverrides: Bool?
        let todoDate: String?
        let podcastEnabled: Bool?
        let podcastHasStudentPosts: Bool?
        let locked: Bool?
        let expanded: Bool?
        let expandedLocked: Bool?
        let sortOrder: RequestBody.DiscussionSortOrderType?
        let sortOrderLocked: Bool?
        let discussionType: RequestBody.DiscussionTopicDiscussionType?
        let isAnnouncement: Bool?
        let specificSections: String?
        let groupCategoryId: String?
        let assignment: RequestBody.AssignmentCreate?
        let checkpoints: [RequestBody.DiscussionCheckpoint]?
        let fileId: String?
        let ungradedDiscussionOverrides: [RequestBody.AssignmentOverrideCreateOrUpdate]?

        public init(
            contextId: String,
            contextType: RequestBody.DiscussionTopicContextType = .course,
            title: String,
            message: String? = nil,
            published: Bool = false,
            requireInitialPost: Bool? = false,
            anonymousState: RequestBody.DiscussionTopicAnonymousStateType? = .off,
            delayedPostAt: String? = nil,
            lockAt: String? = nil,
            isAnonymousAuthor: Bool? = false,
            allowRating: Bool? = false,
            onlyGradersCanRate: Bool? = false,
            onlyVisibleToOverrides: Bool? = false,
            todoDate: String? = nil,
            podcastEnabled: Bool? = false,
            podcastHasStudentPosts: Bool? = false,
            locked: Bool? = false,
            expanded: Bool? = true,
            expandedLocked: Bool? = false,
            sortOrder: RequestBody.DiscussionSortOrderType? = .asc,
            sortOrderLocked: Bool? = false,
            discussionType: RequestBody.DiscussionTopicDiscussionType? = .threaded,
            isAnnouncement: Bool? = false,
            specificSections: String? = "all",
            groupCategoryId: String? = nil,
            assignment: RequestBody.AssignmentCreate? = nil,
            checkpoints: [RequestBody.DiscussionCheckpoint]? = nil,
            fileId: String? = nil,
            ungradedDiscussionOverrides: [RequestBody.AssignmentOverrideCreateOrUpdate]? = nil
        ) {
            self.contextId = contextId
            self.contextType = contextType
            self.title = title
            self.message = message
            self.published = published
            self.requireInitialPost = requireInitialPost
            self.anonymousState = anonymousState
            self.delayedPostAt = delayedPostAt
            self.lockAt = lockAt
            self.isAnonymousAuthor = isAnonymousAuthor
            self.allowRating = allowRating
            self.onlyGradersCanRate = onlyGradersCanRate
            self.onlyVisibleToOverrides = onlyVisibleToOverrides
            self.todoDate = todoDate
            self.podcastEnabled = podcastEnabled
            self.podcastHasStudentPosts = podcastHasStudentPosts
            self.locked = locked
            self.expanded = expanded
            self.expandedLocked = expandedLocked
            self.sortOrder = sortOrder
            self.sortOrderLocked = sortOrderLocked
            self.discussionType = discussionType
            self.isAnnouncement = isAnnouncement
            self.specificSections = specificSections
            self.groupCategoryId = groupCategoryId
            self.assignment = assignment
            self.checkpoints = checkpoints
            self.fileId = fileId
            self.ungradedDiscussionOverrides = ungradedDiscussionOverrides
        }
    }
}

public struct CreateDSDiscussionWithCheckpointsRequestBody: Codable, Equatable {
    let contextId: String
    let title: String
    let message: String?
    let published: Bool
    let assignment: AssignmentCreate
    let checkpoints: [DiscussionCheckpoint]

    public init(
        contextId: String,
        title: String,
        message: String? = nil,
        published: Bool = true,
        assignment: AssignmentCreate,
        checkpoints: [DiscussionCheckpoint]
    ) {
        self.contextId = contextId
        self.title = title
        self.message = message
        self.published = published
        self.assignment = assignment
        self.checkpoints = checkpoints
    }

    public enum DiscussionTopicContextType: String, Codable {
        case course = "Course"
        case group = "Group"
    }

    public enum DiscussionTopicAnonymousStateType: String, Codable {
        case off
        case partial_anonymity
        case full_anonymity
    }

    public enum DiscussionSortOrderType: String, Codable {
        case asc
        case desc
    }

    public enum DiscussionTopicDiscussionType: String, Codable {
        case threaded
        case side_comment
    }

    public struct AssignmentCreate: Codable, Equatable {
        let postToSis: Bool?
        let gradingType: String?
        let importantDates: Bool?
        let assignmentGroupId: String?
        let peerReviews: PeerReviews?
        let onlyVisibleToOverrides: Bool?
        let gradingStandardId: String?
        let forCheckpoints: Bool?
        let suppressAssignment: Bool?
        let assetProcessors: [String]?
        let courseId: String
        let name: String

        public init(
            postToSis: Bool? = false,
            gradingType: String? = "points",
            importantDates: Bool? = false,
            assignmentGroupId: String? = nil,
            peerReviews: PeerReviews? = nil,
            onlyVisibleToOverrides: Bool? = false,
            gradingStandardId: String? = nil,
            forCheckpoints: Bool? = true,
            suppressAssignment: Bool? = false,
            assetProcessors: [String]? = [],
            courseId: String,
            name: String
        ) {
            self.postToSis = postToSis
            self.gradingType = gradingType
            self.importantDates = importantDates
            self.assignmentGroupId = assignmentGroupId
            self.peerReviews = peerReviews
            self.onlyVisibleToOverrides = onlyVisibleToOverrides
            self.gradingStandardId = gradingStandardId
            self.forCheckpoints = forCheckpoints
            self.suppressAssignment = suppressAssignment
            self.assetProcessors = assetProcessors
            self.courseId = courseId
            self.name = name
        }

        public struct PeerReviews: Codable, Equatable {
            let automaticReviews: Bool?
            let count: Int?
            let dueAt: String?
            let enabled: Bool?
        }
    }

    public struct DiscussionCheckpoint: Codable, Equatable {
        let checkpointLabel: String
        let pointsPossible: Double?
        let dates: [CheckpointDate]
        let repliesRequired: Int?

        public init(
            checkpointLabel: String,
            pointsPossible: Double? = 0,
            dates: [CheckpointDate],
            repliesRequired: Int? = 2
        ) {
            self.checkpointLabel = checkpointLabel
            self.pointsPossible = pointsPossible
            self.dates = dates
            self.repliesRequired = repliesRequired
        }

        public struct CheckpointDate: Codable, Equatable {
            let type: String
            let dueAt: Date?
            let unlockAt: Date?
            let lockAt: Date?

            public init(
                type: String = "everyone",
                dueAt: Date? = nil,
                unlockAt: Date? = nil,
                lockAt: Date? = nil
            ) {
                self.type = type
                self.dueAt = dueAt
                self.unlockAt = unlockAt
                self.lockAt = lockAt
            }
        }
    }

    public struct AssignmentOverrideCreateOrUpdate: Codable, Equatable {
        // Add properties as needed
    }
}

public struct CreateDSDiscussionWithCheckpointsResponse: Codable, Equatable {
    let data: Data

    struct Data: Codable, Equatable {
        let createDiscussionTopic: CreateDiscussionTopic

        struct CreateDiscussionTopic: Codable, Equatable {
            let discussionTopic: DiscussionTopic?
            let errors: [ValidationError]?

            struct DiscussionTopic: Codable, Equatable {
                let id: String
                let contextType: String?
                let title: String?
                let message: String?
                let published: Bool?
                let assignment: Assignment?

                private enum CodingKeys: String, CodingKey {
                    case id = "_id"
                    case contextType, title, message, published, assignment
                }

                struct Assignment: Codable, Equatable {
                    let id: String
                    let name: String?
                    let pointsPossible: Double?
                    let checkpoints: [Checkpoint]?

                    private enum CodingKeys: String, CodingKey {
                        case id = "_id"
                        case name, pointsPossible, checkpoints
                    }

                    struct Checkpoint: Codable, Equatable {
                        let dueAt: String?
                        let name: String?
                        let pointsPossible: Double?
                        let tag: String?
                    }
                }
            }

            struct ValidationError: Codable, Equatable {
                let attribute: String?
                let message: String?
            }
        }
    }
}
