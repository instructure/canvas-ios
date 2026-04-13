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

final class ManageOfflineContentInteractorPreview: ManageOfflineContentInteractor {
    func getCourses(ignoreCache: Bool) -> AnyPublisher<[OfflineCourseItem], Error> {
        Just(
            [
                OfflineCourseItem(
                    id: "course1",
                    name: "Mathematics 101",
                    size: "1.2 GB",
                    isExpanded: true,
                    isSelected: false,
                    subItems: [
                        OfflineSubItem(
                            id: "file1",
                            name: "Lecture 1.pdf",
                            size: "50 MB",
                            sizeInBytes: 1000,
                            isSelected: true,
                            mimeClass: "pdf"
                        ),
                        OfflineSubItem(
                            id: "file2",
                            name: "Lecture 2.pdf",
                            size: "60 MB",
                            sizeInBytes: 2000,
                            isSelected: true,
                            mimeClass: "doc"
                        ),
                        OfflineSubItem(
                            id: "file3",
                            name: "Lecture 3.pdf",
                            size: "55 MB",
                            sizeInBytes: 30000,
                            isSelected: true,
                            mimeClass: "ppt"
                        )
                    ]
                )
            ]
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}

#endif
