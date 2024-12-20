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

import SwiftUI

public class K5ResourcesViewModel: ObservableObject {
    @Published public var homeroomInfos: [K5ResourcesHomeroomInfoViewModel] = []
    @Published public var applications: [K5ResourcesApplicationViewModel] = []
    @Published public var contacts: [K5ResourcesContactViewModel] = []

    public var showInfoTitle: Bool {
        return homeroomInfos.count > 1
    }

    private lazy var courses = AppEnvironment.shared.subscribe(GetCourses(enrollmentState: .active)) { [weak self] in
        self?.coursesRefreshed()
    }
    private var applicationsRequest: APITask?
    private var contactInfoService: StaffContactInfoService?

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
            guard let name = $0.name, let syllabus = $0.syllabusBody, !syllabus.isEmpty else { return nil }
            return K5ResourcesHomeroomInfoViewModel(homeroomName: name, htmlContent: syllabus)
        }
        let nonHomeroomCourses = courses.all.filter { !$0.isHomeroomCourse }
        requestApplications(for: nonHomeroomCourses)
        requestStaffInfo(for: homeroomCourses)
    }

    // MARK: - Applications

    private func requestApplications(for courses: [Course]) {
        guard applicationsRequest == nil else { return }
        let request = GetCourseNavigationToolsRequest(courseContextsCodes: courses.map { $0.canvasContextID })
        applicationsRequest = AppEnvironment.shared.api.makeRequest(request) { [weak self] tools, _, _ in
            self?.handleApplicationsResponse(tools ?? [])
        }
    }

    private func handleApplicationsResponse(_ tools: [CourseNavigationTool]) {
        applicationsRequest = nil
        let validTools = tools.filter {
            ($0.course_navigation?.text != nil || $0.name != nil) &&
            $0.context_name != nil &&
            $0.id != nil &&
            $0.context_id != nil
        }
        let toolsByNames = Dictionary(grouping: validTools) { $0.course_navigation?.text ?? $0.name! }
        var applications: [K5ResourcesApplicationViewModel] = toolsByNames.map { name, tools in
            var routesAndSubjectNames = tools.map { (name: $0.context_name!, route: URL(string: "/courses/\($0.context_id!)/external_tools/\($0.id!)")!) }
            routesAndSubjectNames.sort { $0.name < $1.name }
            return K5ResourcesApplicationViewModel(image: tools.first?.course_navigation?.icon_url, name: name, routesBySubjectNames: routesAndSubjectNames)
        }
        applications = Array(Set(applications)).sorted { $0.name < $1.name }

        performUIUpdate {
            self.applications = applications
        }
    }

    // MARK: - Staff Info

    private func requestStaffInfo(for courses: [Course]) {
        guard contactInfoService == nil else { return }
        contactInfoService = StaffContactInfoService(courses: courses) { [weak self] users in
            self?.handleStaffInfoResponse(users)
        }
    }

    private func handleStaffInfoResponse(_ users: [APIUser]) {
        contactInfoService = nil

        var contacts: [K5ResourcesContactViewModel] = users.map { K5ResourcesContactViewModel($0, courses: courses.all) }
        contacts = Array(Set(contacts)).sorted()

        performUIUpdate {
            self.contacts = contacts
        }
    }
}

extension K5ResourcesViewModel: Refreshable {

    @available(*, renamed: "refresh()")
    public func refresh(completion: @escaping () -> Void) {
        Task {
            await refresh()
            completion()
        }
    }

    public func refresh() async {
        return await withCheckedContinuation { continuation in
            courses.refresh(force: true) {_ in
                continuation.resume()
            }
        }
    }
}
