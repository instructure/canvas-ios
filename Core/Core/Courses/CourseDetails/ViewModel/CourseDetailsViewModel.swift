//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class CourseDetailsViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }

    @Published public private(set) var state: ViewModelState<[CourseDetailsCellViewModel]> = .loading
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var hideColorOverlay: Bool?
    @Published public private(set) var homeLabel: String?
    @Published public private(set) var homeSubLabel: String?
    @Published public private(set) var homeRoute: URL?

    public var showHome: Bool { !isTeacher }
    public var showSettings: Bool { isTeacher }
    public var showStudentView: Bool { isTeacher }
    public var courseName: String { course.first?.name ?? "" }
    public var imageURL: URL? { course.first?.imageDownloadURL }
    public var termName: String { course.first?.termName ?? "" }
    public var settingsRoute: URL? {
        guard let course = course.first else { return nil }
        return URL(string: "courses/\(course.id)/settings")
    }

    @Environment(\.appEnvironment) private var env

    private var isTeacher: Bool { env.app == .teacher }
    private let context: Context
    private var attendanceToolID: String?
    private var applicationsRequest: APITask?
    private let mobileSupportedTabs: [TabName] = [.assignments, .quizzes, .discussions, .announcements, .people, .pages, .files, .modules, .syllabus]
    private lazy var colors = env.subscribe(GetCustomColors())
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.courseDidUpdate()
    }
    private lazy var tabs = env.subscribe(GetContextTabs(context: context)) { [weak self] in
        self?.updateTabs()
    }
    private lazy var settings: Store<GetUserSettings> = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.hideColorOverlay = self?.settings.first?.hideDashcardColorOverlays == true
    }
    private lazy var permissions = env.subscribe(GetContextPermissions(context: context, permissions: [.useStudentView])) { [weak self] in
        self?.updateTabs()
    }

    public init(context: Context) {
        self.context = context
    }

    // MARK: - Preview Support

#if DEBUG

    init(state: ViewModelState<[CourseDetailsCellViewModel]>) {
        self.state = state
        self.context = .course("1")
    }

#endif

    // MARK: Preview Support -

    public func viewDidAppear() {
        requestApplications()
        permissions.refresh()
        settings.refresh()
        course.refresh()
        colors.refresh()
    }

    // MARK: - Private Methods

    private func courseDidUpdate() {
        guard let course = course.first else { return }
        courseColor = course.color
        setupHome(course: course)
        tabs.exhaust()
    }

    private func setupHome(course: Course) {
        guard let defaultView = course.defaultView else { return }
        homeRoute = URL(string: "courses/\(course.id)/\(defaultView.rawValue)")

        switch course.defaultView {
        case .assignments:
            homeSubLabel = NSLocalizedString("Assignments", comment: "")
        case .feed:
            homeSubLabel = NSLocalizedString("Recent Activity", comment: "")
            homeRoute = URL(string: "courses/\(course.id)/activity_stream")
        case .modules:
            homeSubLabel = NSLocalizedString("Course Modules", comment: "")
        case .syllabus:
            homeSubLabel = NSLocalizedString("Syllabus", comment: "")
        case .wiki:
            homeSubLabel = NSLocalizedString("Front Page", comment: "")
            homeRoute = URL(string: "courses/\(course.id)/pages/front_page")
        case .none:
            return
        }
    }

    private func updateTabs() {
        guard let course = course.first, tabs.requested, !tabs.pending, !tabs.hasNextPage, permissions.requested, !permissions.pending, applicationsRequest == nil else { return }
        var tabs = tabs.all
        tabs = tabs.filter {
            if !isTeacher || $0.id.contains("external_tool") {
                return $0.hidden != true
            }
            // Only show tabs supported on mobile
            return mobileSupportedTabs.contains($0.name)
        }.sorted(by: {$0.position < $1.position })

        if let index = tabs.firstIndex(where: { $0.id == "home" }) {
            let homeTab = tabs.remove(at: index)
            homeLabel = homeTab.label
        }
        var cellViewModels = tabs.map { CourseDetailsCellViewModel(tab: $0, course: course, attendanceToolID: attendanceToolID) }
        if permissions.first?.useStudentView == true {
            let studentViewCellModel = CourseDetailsCellViewModel.studentView(course: course)
            cellViewModels.append(studentViewCellModel)
        }
        state = (cellViewModels.isEmpty ? .empty : .data(cellViewModels))
    }

    // MARK: Applications

    private func requestApplications() {
        guard applicationsRequest == nil else { return }
        let request = GetCourseNavigationToolsRequest(courseContextsCodes: [context.canvasContextID])
        applicationsRequest = AppEnvironment.shared.api.makeRequest(request) { [weak self] tools, _, _ in
            self?.handleApplicationsResponse(tools ?? [])
        }
    }

    private func handleApplicationsResponse(_ tools: [CourseNavigationTool]) {
        applicationsRequest = nil
        let attendanceTool = tools.first {
            let attendancePatterns = ["rollcall.instructure.com", "rollcall.beta.instructure.com"]
            if let urlString = $0.url?.absoluteString {
                return attendancePatterns.contains(where: urlString.contains)
            }
            return false
        }
        attendanceToolID =  attendanceTool?.id
        performUIUpdate {
            self.updateTabs()
        }
    }
}

extension CourseDetailsViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        course.refresh(force: true)
        tabs.exhaust(force: true) { [weak self] _ in
            if self?.tabs.hasNextPage == false {
                completion()
            }
            return true
        }
    }
}
