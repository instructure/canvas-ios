//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import Foundation

protocol CourseSyncInteractor {
    func downloadContent(for entries: [CourseSyncSelectorEntry]) -> AnyPublisher<[CourseSyncSelectorEntry], Error>
}

protocol CourseSyncContentInteractor {
    var associatedTabType: TabName { get }
    func getContent(courseId: String) -> AnyPublisher<Void, Error>
}

final class CourseSyncInteractorLive: CourseSyncInteractor {
    private let contentInteractors: [CourseSyncContentInteractor]
    private var courseSyncEntries = CurrentValueSubject<[CourseSyncSelectorEntry], Error>.init([])

    init(pagesDownloader: CourseSyncPagesInteractor = CourseSyncPagesInteractorLive()) {
        contentInteractors = [
            pagesDownloader
        ]
    }

    func downloadContent(for entries: [CourseSyncSelectorEntry]) -> AnyPublisher<[CourseSyncSelectorEntry], Error> {
        courseSyncEntries.send(entries)

        return Publishers.Sequence(sequence: entries.enumerated())
            .flatMap { index, entry in
                Publishers.Zip(
                    self.downloadTabContent(for: entry, index: index, tabName: .assignments),
                    self.downloadTabContent(for: entry, index: index, tabName: .pages)
                )
                .updateErrorState {
                    self.setState(
                        selection: .course(index),
                        state: .error
                    )
                }
                .updateDownloadedState {
                    self.setState(
                        selection: .course(index),
                        state: .downloaded
                    )
                }
                .eraseToAnyPublisher()
            }
            .collect()
            .flatMap { _ in self.courseSyncEntries }
            .print()
            .eraseToAnyPublisher()
    }

    private func downloadTabContent(for entry: CourseSyncSelectorEntry, index: Int, tabName: TabName) -> AnyPublisher<Void, Error> {
        if let tab = entry.tabs.first(where: { $0.type == tabName }),
           tab.selectionState == .selected,
           let tabIndex = entry.tabs.firstIndex(where: { $0.type == tabName }),
           let interactor = contentInteractors.first(where: { $0.associatedTabType == tabName }) {
            return interactor.getContent(courseId: entry.id)
                .updateErrorState {
                    self.setState(
                        selection: .tab(index, tabIndex),
                        state: .error
                    )
                }
                .updateDownloadedState {
                    self.setState(
                        selection: .tab(index, tabIndex),
                        state: .downloaded
                    )
                }
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    private func setState(selection: CourseEntrySelection, state: CourseSyncSelectorEntry.State) {
        var entries = courseSyncEntries.value

        switch selection {
        case let .course(courseIndex):
            entries[courseIndex].updateCourseState(state: state)
        case let .tab(courseIndex, tabIndex):
            entries[courseIndex].updateTabState(index: tabIndex, state: state)
        case let .file(courseIndex, fileIndex):
            entries[courseIndex].updateFileState(index: fileIndex, state: state)
        }

        courseSyncEntries.send(entries)
    }
}

private extension Publisher {
    func updateErrorState(_ stateUpdate: @escaping () -> Void) -> AnyPublisher<Self.Output, Error> {
        return tryCatch { error -> AnyPublisher<Self.Output, Error> in
            stateUpdate()
            throw error
        }
        .eraseToAnyPublisher()
    }

    func updateDownloadedState(_ stateUpdate: @escaping () -> Void) -> AnyPublisher<Self.Output, Self.Failure> {
        handleEvents(
            receiveOutput: { _ in
                stateUpdate()
            }
        )
        .eraseToAnyPublisher()
    }
}
