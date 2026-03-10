//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Observation

@Observable
final class LearningLibraryRecommendationListViewModel {

    var sections: [LearningLibrarySectionModel] = []

    init() {
        loadItems()
    }

    func loadItems() {
        sections = [
            .init(
                id: "section-1",
                name: "Recommended for You",
                items: [
                    .init(
                        id: "1",
                        name: "Introduction to Swift Programming",
                        imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                        itemType: .assignment,
                        estimatedTime: "45 mins",
                        isRecommended: true,
                        isCompleted: false,
                        isBookmarked: false,
                        numberOfUnits: 12
                    ),
                    .init(
                        id: "2",
                        name: "SwiftUI Fundamentals",
                        imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                        itemType: .assessment,
                        estimatedTime: "60 mins",
                        isRecommended: true,
                        isCompleted: false,
                        isBookmarked: true,
                        numberOfUnits: 8
                    ),
                    .init(
                        id: "3",
                        name: "iOS App Architecture",
                        imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                        itemType: .assignment,
                        estimatedTime: "30 mins",
                        isRecommended: true,
                        isCompleted: true,
                        isBookmarked: false,
                        numberOfUnits: 15
                    )
                ]
            ),
            .init(
                id: "section-2",
                name: "Continue Learning",
                items: [
                    .init(
                        id: "4",
                        name: "Advanced Combine Techniques",
                        imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                        itemType: .course,
                        estimatedTime: "90 mins",
                        isRecommended: false,
                        isCompleted: false,
                        isBookmarked: true,
                        numberOfUnits: 20
                    )
                ]
            ),
            .init(
                id: "section-3",
                name: "Career Development",
                items: [
                    .init(
                        id: "5",
                        name: "Resume Building Workshop",
                        imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                        itemType: .assignment,
                        estimatedTime: "25 mins",
                        isRecommended: false,
                        isCompleted: false,
                        isBookmarked: false,
                        numberOfUnits: 5
                    ),
                    .init(
                        id: "6",
                        name: "Interview Preparation",
                        imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                        itemType: .file,
                        estimatedTime: "120 mins",
                        isRecommended: false,
                        isCompleted: false,
                        isBookmarked: false,
                        numberOfUnits: 30
                    ),
                    .init(
                        id: "7",
                        name: "Networking Strategies",
                        imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                        itemType: .assignment,
                        estimatedTime: "40 mins",
                        isRecommended: false,
                        isCompleted: true,
                        isBookmarked: true,
                        numberOfUnits: 10
                    ),
                    .init(
                        id: "8",
                        name: "Portfolio Showcase",
                        imageURL: URL(string: "https://img.freepik.com/free-photo/abstract-flowing-neon-wave-background_53876-101942.jpg"),
                        itemType: .assessment,
                        estimatedTime: "50 mins",
                        isRecommended: false,
                        isCompleted: false,
                        isBookmarked: false,
                        numberOfUnits: 18
                    )
                ]
            )
        ]
    }
}
