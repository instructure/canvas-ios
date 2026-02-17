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

#if DEBUG
import Combine
import Foundation

final class LearningLibraryInteractorPreview: LearningLibraryInteractor {
    func getLearnLibraryCollections(ignoreCache: Bool) -> AnyPublisher<[LearningLibrarySectionModel], Error> {
        Just(mockCollections)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getLearnLibraryItems(ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        Just(mockItems)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func bookmark(id: String) -> AnyPublisher<LearningLibraryCardModel, Error> {
        let item = mockItems.first { $0.id == id } ?? mockItems[0]
        var updatedItem = item
        updatedItem.isBookmarked.toggle()
        return Just(updatedItem)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func enroll(id: String) -> AnyPublisher<LearningLibraryCardModel, Error> {
        let item = mockItems.first { $0.id == id } ?? mockItems[0]
        var updatedItem = item
        updatedItem.isEnrolled = true
        return Just(updatedItem)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private var mockItems: [LearningLibraryCardModel] {
        [
            LearningLibraryCardModel(
                id: "1",
                itemId: "item-1",
                name: "Introduction to Swift",
                imageURL: URL(string: "https://example.com/swift.jpg"),
                itemType: .course,
                estimatedTime: "120",
                isRecommended: true,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: 8,
                isEnrolled: false,
                isInProgress: false,
                libraryId: "lib-1"
            ),
            LearningLibraryCardModel(
                id: "2",
                itemId: "item-2",
                name: "Advanced iOS Development",
                imageURL: URL(string: "https://example.com/ios.jpg"),
                itemType: .course,
                estimatedTime: "240",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: true,
                numberOfUnits: 12,
                isEnrolled: true,
                isInProgress: true,
                courseEnrollmentId: "enroll-2",
                libraryId: "lib-1"
            ),
            LearningLibraryCardModel(
                id: "3",
                itemId: "item-3",
                name: "SwiftUI Fundamentals",
                imageURL: URL(string: "https://example.com/swiftui.jpg"),
                itemType: .program,
                estimatedTime: "180",
                isRecommended: true,
                isCompleted: true,
                isBookmarked: true,
                numberOfUnits: 10,
                isEnrolled: true,
                isInProgress: false,
                courseEnrollmentId: "enroll-3",
                libraryId: "lib-1"
            ),
            LearningLibraryCardModel(
                id: "4",
                itemId: "item-4",
                name: "API Integration Guide",
                imageURL: URL(string: "https://example.com/api.jpg"),
                itemType: .page,
                estimatedTime: "60",
                isRecommended: false,
                isCompleted: false,
                isBookmarked: false,
                numberOfUnits: nil,
                isEnrolled: false,
                isInProgress: false,
                libraryId: "lib-2"
            )
        ]
    }

    private var mockCollections: [LearningLibrarySectionModel] {
        [
            LearningLibrarySectionModel(
                id: "collection-1",
                name: "Recommended Courses",
                hasMoreItems: true,
                items: Array(mockItems.prefix(2))
            ),
            LearningLibrarySectionModel(
                id: "collection-2",
                name: "Development Resources",
                hasMoreItems: false,
                items: Array(mockItems.suffix(2))
            )
        ]
    }
}
#endif
