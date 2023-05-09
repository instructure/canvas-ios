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

protocol CourseSyncDownloader {
    func downloadContent(for entries: [CourseSyncSelectorEntry]) -> AnyPublisher<[CourseSyncSelectorEntry], Error>
}

final class CourseSyncDownloaderLive: CourseSyncDownloader {
    private let pagesDownloader: CourseSyncPagesDownloader
    private var courseSyncEntries = CurrentValueSubject<[CourseSyncSelectorEntry], Error>.init([])

    init(pagesDownloader: CourseSyncPagesDownloader = CourseSyncPagesDownloaderLive()) {
        self.pagesDownloader = pagesDownloader
    }

    func downloadContent(for entries: [CourseSyncSelectorEntry]) -> AnyPublisher<[CourseSyncSelectorEntry], Error> {
        courseSyncEntries.send(entries)

        return Publishers.Sequence(sequence: entries.enumerated())
            .flatMap { index, entry in
                Publishers.Zip(
                    self.downloadPages(for: entry, index: index),
                    self.downloadAssignments(for: entry, index: index)
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

    func downloadPages(for entry: CourseSyncSelectorEntry, index: Int) -> AnyPublisher<Void, Error> {
        if let pagesTab = entry.tabs.first(where: { $0.type == .pages }),
           pagesTab.isSelected,
           let pagesTabIndex = entry.tabs.firstIndex(where: { $0.type == .pages }) {
            return pagesDownloader.getPages(for: entry)
                .updateErrorState {
                    self.setState(
                        selection: .tab(index, pagesTabIndex),
                        state: .error
                    )
                }
                .updateDownloadedState {
                    self.setState(
                        selection: .tab(index, pagesTabIndex),
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

    func downloadAssignments(for _: CourseSyncSelectorEntry, index _: Int) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
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
