//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct K5ResourcesHomeroomInfo: Equatable, Identifiable {
    public var id: String { homeroomName }

    public let homeroomName: String
    public let htmlContent: String
}

public struct K5ResourcesApplication: Equatable, Identifiable {
    public var id: String { name }

    public let image: URL?
    public let name: String
    public let route: String
}

public struct K5ResourcesContact: Equatable, Identifiable {
    public var id: String { route }

    public let image: URL?
    public let name: String
    public let role: String
    public let route: String
}

public class K5ResourcesViewModel: ObservableObject {
    @Published public var homeroomInfos: [K5ResourcesHomeroomInfo] = []
    @Published public var applications: [K5ResourcesApplication] = []
    @Published public var contacts: [K5ResourcesContact] = []

    private lazy var courses = AppEnvironment.shared.subscribe(GetCourses(enrollmentState: nil)) { [weak self] in
        self?.coursesRefreshed()
    }

    public init() {

    }

    public func viewDidAppear() {
        courses.refresh()
    }

    private func coursesRefreshed() {
        if courses.pending || !courses.requested {
            return
        }

        let homeroomCourses = courses.all.filter { $0.isHomeroomCourse }
        homeroomInfos = homeroomCourses.compactMap {
            guard let name = $0.name, let syllabus = $0.syllabusBody else { return nil }
            return K5ResourcesHomeroomInfo(homeroomName: name, htmlContent: syllabus)
        }
    }
}

extension K5ResourcesViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        courses.refresh(force: true) {_ in
            completion()
        }
    }
}
