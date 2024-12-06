//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class GetCoursesInteractorPreview: GetCoursesInteractor {
    func getCourses() -> AnyPublisher<[HCourse], Never> {
        Just([course])
            .eraseToAnyPublisher()
    }

    private var course: HCourse {
        .init(
            id: "1",
            name: "learning AI for business",
            imageURL: URL(
                string: "https://www.mbaandbeyond.com/wp-content/uploads/2024/05/How-is-AI-revolutionizing-MBA-programs-and-shaping-the-future-of-business-education.png"
            ),
            overviewDescription: "String",
            modules: [
                .init(
                    id: "12",
                    name: "Introduction",
                    courseID: "1",
                    items: [
                        .init(id: "15", title: "Sub title", htmlURL: nil),
                        .init(id: "20", title: "Sub title 44", htmlURL: nil)
                    ]
                ),
                .init(id: "13", name: "Assginemts", courseID: "2", items: [.init(id: "14", title: "Sub title 2", htmlURL: nil)])
            ]
        )
    }
}
#endif
