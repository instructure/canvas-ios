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
        case empty(title: String, message: String)
        case data(T)
    }

    public let selectionViewModel = CourseDetailsSelectionViewModel()
    public let headerViewModel = CourseDetailsHeaderViewModel()
    @Published public private(set) var state: ViewModelState<[CourseDetailsCellViewModel]> = .loading
    @Published public private(set) var courseColor: UIColor = .clear
    @Published public private(set) var homeLabel: String?
    @Published public private(set) var homeSubLabel: String?
    @Published public private(set) var homeRoute: URL?

    public var showHome: Bool { !isTeacher }
    public var showSettings: Bool { isTeacher }
    public var showStudentView: Bool { isTeacher }
    public var courseName: String { course.first?.name ?? "" }
    public var settingsRoute: URL? {
        guard let course = course.first else { return nil }
        return URL(string: "courses/\(course.id)/settings")
    }

    @Environment(\.appEnvironment) private var env

    private var isTeacher: Bool { env.app == .teacher }
    private let context: Context
    private var attendanceToolID: String?
    private var attendanceToolRequest: APITask?
    private let mobileSupportedTabs: [TabName] = [.assignments, .quizzes, .discussions, .announcements, .people, .pages, .files, .modules, .syllabus]
    private lazy var colors = env.subscribe(GetCustomColors())
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.courseDidUpdate()
    }
    private lazy var tabs = env.subscribe(GetContextTabs(context: context)) { [weak self] in
        self?.updateTabs()
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
        headerViewModel.viewDidAppear()
        requestAttendanceTool()
        permissions.refresh()
        course.refresh()
        colors.refresh()
    }

    public func retryAfterError() {
        state = .loading
        refresh()
    }

    // MARK: - Private Methods

    private func courseDidUpdate() {
        guard let course = course.first else { return }
        headerViewModel.courseUpdated(course)
        courseColor = course.color
        setupHome(course: course)
        tabs.exhaust()
    }

    private func setupHome(course: Course) {
        guard let defaultView = course.defaultView else { return }
        var homeRoute = URL(string: "courses/\(course.id)/\(defaultView.rawValue)")

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
            break
        }

        if self.homeRoute != homeRoute {
            self.homeRoute = homeRoute
        }
    }

    private func updateTabs() {
        guard let course = course.first, tabs.requested, !tabs.pending, !tabs.hasNextPage, permissions.requested, !permissions.pending, attendanceToolRequest == nil else { return }

        if tabs.error != nil {
            state = .empty(title: NSLocalizedString("Something went wrong", comment: ""), message: NSLocalizedString("There was an unexpected error. Please try again.", comment: ""))
            return
        }

        var tabs = tabs.all
        tabs = tabs.filter {
            if !isTeacher || $0.id.contains("external_tool") {
                return $0.hidden != true
            }
            // Only show tabs supported on mobile
            return mobileSupportedTabs.contains($0.name)
        }.sorted(by: { $0.position < $1.position })

        if let index = tabs.firstIndex(where: { $0.id == "home" }) {
            let homeTab = tabs.remove(at: index)
            homeLabel = homeTab.label
        }

        var cellViewModels: [CourseDetailsCellViewModel] = tabs.map {
            if let attendanceToolID = attendanceToolID, $0.id == "context_external_tool_" + attendanceToolID {
                return AttendanceCellViewModel(tab: $0, course: course, attendanceToolID: attendanceToolID)
            } else if $0.type == .external, let url = $0.url {
                return LTICellViewModel(tab: $0, course: course, url: url)
            } else {
                return GenericCellViewModel(tab: $0, course: course)
            }
        }

        if permissions.first?.useStudentView == true {
            let studentViewCellModel = StudentViewCellViewModel(course: course)
            cellViewModels.append(studentViewCellModel)
        }

        state = .data(cellViewModels)
    }

    // MARK: Attendance Tool

    private func requestAttendanceTool() {
        guard attendanceToolRequest == nil else { return }
        let request = GetCourseNavigationToolsRequest(courseContextsCodes: [context.canvasContextID])
        attendanceToolRequest = AppEnvironment.shared.api.makeRequest(request) { [weak self] tools, _, _ in
            self?.handleAttendanceToolResponse(tools ?? [])
        }
    }

    private func handleAttendanceToolResponse(_ tools: [CourseNavigationTool]) {
        attendanceToolRequest = nil
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
        requestAttendanceTool()
        permissions.refresh(force: true)
        colors.refresh(force: true)
        course.refresh(force: true)
        tabs.exhaust(force: true) { [weak self] _ in
            if self?.tabs.hasNextPage == false {
                completion()
            }
            return true
        }
    }
}
