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
struct APIModuleItemsDiscussionCheckpoints: Codable, Equatable {
    typealias DiscussionCheckpoint = DataRaw.Course.ModulesConnection.Edge.Node.ModuleItem.Content.Checkpoint

    struct Data: Codable, Equatable {
        let checkpoints: [DiscussionCheckpoint]
        let replyToEntryRequiredCount: Int
    }

    var dataPerModuleItemId: [String: Data] {
        var result: [String: Data] = [:]

        for edge in data.course.modulesConnection.edges {
            for item in edge.node.moduleItems {
                if let content = item.content,
                   let checkpoints = content.checkpoints?.nilIfEmpty,
                   let replyToEntryRequiredCount = content.replyToEntryRequiredCount {
                    result[item._id] = Data(
                        checkpoints: checkpoints,
                        replyToEntryRequiredCount: replyToEntryRequiredCount
                    )
                }
            }
        }

        return result
    }

    let data: DataRaw

    struct DataRaw: Codable, Equatable {
        let course: Course

        struct Course: Codable, Equatable {
            let modulesConnection: ModulesConnection

            struct ModulesConnection: Codable, Equatable {
                let edges: [Edge]

                struct Edge: Codable, Equatable {
                    let node: Node

                    struct Node: Codable, Equatable {
                        let moduleItems: [ModuleItem]

                        struct ModuleItem: Codable, Equatable {
                            let _id: String
                            let content: Content?

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

#if DEBUG

extension APIModuleItemsDiscussionCheckpoints {
    init(dataPerModuleItemId: [String: Data]) {
        self.data = .init(
            course: .init(
                modulesConnection: .init(
                    edges: [
                        .init(
                            node: .init(
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
                        )
                    ]
                )
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
