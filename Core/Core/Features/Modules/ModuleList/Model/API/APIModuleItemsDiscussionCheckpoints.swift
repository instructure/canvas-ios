//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Foundation

// Contains DiscussionCheckpoint data for multiple ModuleItems.
struct APIModuleItemsDiscussionCheckpoints: PagedResponse, Equatable {

    // MARK: - Paging

    typealias Module = ResponseData.Course.ModulesConnection.Edge
    typealias Page = [Module]

    var pageInfo: APIPageInfo? {
        data.course.modulesConnection.pageInfo
    }
    var page: [Module] {
        data.course.modulesConnection.edges
    }

    // MARK: - Response data

    let data: ResponseData

    struct ResponseData: Codable, Equatable {
        let course: Course

        struct Course: Codable, Equatable {
            let modulesConnection: ModulesConnection

            struct ModulesConnection: Codable, Equatable {
                let pageInfo: APIPageInfo?
                let edges: [Edge]

                struct Edge: Codable, Equatable {
                    let node: Node

                    struct Node: Codable, Equatable {
                        let moduleItems: [ModuleItem]

                        struct ModuleItem: Codable, Equatable {
                            let _id: String
                            let content: Content

                            struct Content: Codable, Equatable {
                                let checkpoints: [Checkpoint]?
                                let replyToEntryRequiredCount: Int?

                                struct Checkpoint: Codable, Equatable {
                                    let tag: String
                                    let dueAt: Date?
                                    let pointsPossible: Double?
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Output data

extension APIModuleItemsDiscussionCheckpoints {
    typealias DiscussionCheckpoint = ResponseData.Course.ModulesConnection.Edge.Node.ModuleItem.Content.Checkpoint

    struct Data: Codable, Equatable {
        let checkpoints: [DiscussionCheckpoint]
        let replyToEntryRequiredCount: Int
    }
}

extension APIModuleItemsDiscussionCheckpoints.Page {
    var dataPerModuleItemId: [String: APIModuleItemsDiscussionCheckpoints.Data] {
        var result: [String: APIModuleItemsDiscussionCheckpoints.Data] = [:]

        for edge in self {
            for item in edge.node.moduleItems {
                if let checkpoints = item.content.checkpoints?.nilIfEmpty,
                   let replyToEntryRequiredCount = item.content.replyToEntryRequiredCount {
                    result[item._id] = .init(
                        checkpoints: checkpoints,
                        replyToEntryRequiredCount: replyToEntryRequiredCount
                    )
                }
            }
        }

        return result
    }
}

#if DEBUG

// MARK: - Make methods

extension APIModuleItemsDiscussionCheckpoints {
    typealias ModuleItem = ResponseData.Course.ModulesConnection.Edge.Node.ModuleItem

    static func make(
        apiPageInfo: APIPageInfo? = nil,
        moduleItems: [ModuleItem] = []
    ) -> Self {
        .init(
            data: .init(
                course: .init(
                    modulesConnection: .init(
                        pageInfo: apiPageInfo,
                        edges: [
                            .init(
                                node: .init(
                                    moduleItems: moduleItems
                                )
                            )
                        ]
                    )
                )
            )
        )
    }

    static func make(
        pageInfo: APIPageInfo? = nil,
        dataPerModuleItemId: [String: Data] = [:]
    ) -> Self {
        .make(
            apiPageInfo: pageInfo,
            moduleItems: dataPerModuleItemId.map {
                .init(
                    _id: $0.key,
                    content: .init(
                        checkpoints: $0.value.checkpoints,
                        replyToEntryRequiredCount: $0.value.replyToEntryRequiredCount
                    )
                )
            }
        )
    }
}

extension APIModuleItemsDiscussionCheckpoints.ModuleItem {
    static func make(
        id: String = "",
        checkpoints: [APIModuleItemsDiscussionCheckpoints.DiscussionCheckpoint]? = [],
        replyToEntryRequiredCount: Int? = nil
    ) -> Self {
        .init(
            _id: id,
            content: .init(
                checkpoints: checkpoints,
                replyToEntryRequiredCount: replyToEntryRequiredCount
            )
        )
    }
}

extension APIModuleItemsDiscussionCheckpoints.Data {
    static func make(
        checkpoints: [APIModuleItemsDiscussionCheckpoints.DiscussionCheckpoint] = [],
        replyToEntryRequiredCount: Int = 0
    ) -> Self {
        .init(
            checkpoints: checkpoints,
            replyToEntryRequiredCount: replyToEntryRequiredCount
        )
    }
}

extension APIModuleItemsDiscussionCheckpoints.DiscussionCheckpoint {
    static func make(
        tag: String = "",
        dueAt: Date? = nil,
        pointsPossible: Double? = nil
    ) -> Self {
        .init(
            tag: tag,
            dueAt: dueAt,
            pointsPossible: pointsPossible
        )
    }
}

#endif
