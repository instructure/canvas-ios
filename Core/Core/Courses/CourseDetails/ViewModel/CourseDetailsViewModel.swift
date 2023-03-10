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

import Combine
import SwiftUI

public class CourseDetailsViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty(title: String, message: String)
        case data(T)
    }

    public lazy var selectionViewModel = ListSelectionViewModel(defaultSelection: (showHome ? 0 : nil))
    public let splitModeObserver = SplitViewModeObserver()
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
    public var navigationBarTitle: String { course.first?.courseCode ?? "" }
    public var settingsRoute: URL? {
        guard let course = course.first else { return nil }
        return URL(string: "courses/\(course.id)/settings")
    }
    public var courseID: String {
        course.first?.id ?? ""
    }

    private let env = AppEnvironment.shared
    private var isTeacher: Bool { env.app == .teacher }
    private let context: Context
    private var attendanceToolID: String?
    private var attendanceToolRequest: APITask?
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

    private var subscriptions = Set<AnyCancellable>()

    public init(context: Context) {
        self.context = context
        bindSplitViewModeObserverToSelectionManager()
        bindCellSelectionStateToCellViewModels()
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
        selectionViewModel.viewDidAppear()
        headerViewModel.viewDidAppear()
        requestAttendanceTool()
        permissions.refresh()
        course.refresh()
        colors.refresh()
    }

    public func retryAfterError() {
        state = .loading
        Task {
            await refresh()
        }
    }

    // MARK: - Private Methods

    private func bindCellSelectionStateToCellViewModels() {
        selectionViewModel.selectedIndexPublisher
            .sink { [weak self] selectedIndex in
                guard let self = self, case .data(let cellViewModels) = self.state else { return }
                self.updateCellSelectionStates(on: cellViewModels, selectedIndex: selectedIndex)
            }
            .store(in: &subscriptions)
    }

    private func bindSplitViewModeObserverToSelectionManager() {
        splitModeObserver.isCollapsed
            .subscribe(selectionViewModel.isSplitViewCollapsed)
            .store(in: &subscriptions)
    }

    private func updateCellSelectionStates(on cells: [CourseDetailsCellViewModel], selectedIndex: Int?) {
        for (index, cell) in cells.enumerated() {
            // if home cell is shown we increase the cell index since the home cell is managed outside of this array
            let cellIndex = index + (showHome ? 1 : 0)
            cell.isHighlighted = (selectedIndex == cellIndex)
        }
    }

    private func courseDidUpdate() {
        guard let course = course.first else { return }
        headerViewModel.courseUpdated(course)
        courseColor = course.color
        setupHome(course: course)
        tabs.exhaust()
    }

    private func setupHome(course: Course) {
        // Even if there's no home view for the course we still want to reset the split detail view when moving back/to the course details
        if !showHome {
            // We need to drop the # from color otherwise it will be treated as the fragment of the url and not the value of contextColor
            homeRoute = URL(string: "/empty?contextColor=\(courseColor.resolvedColor(with: .light).darkenToEnsureContrast(against: .textLightest).hexString.dropFirst())")
            return
        }

        guard let defaultView = course.defaultView else { return }

        homeSubLabel = defaultView.homeSubLabel
        let homeRoute = defaultView.homeRoute(courseID: course.id)

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

        var tabs = tabs.all.filteredTabsForCourseHome(isStudent: !isTeacher)

        if let index = tabs.firstIndex(where: { $0.id == "home" }) {
            let homeTab = tabs.remove(at: index)
            homeLabel = homeTab.label
        }

        var cellViewModels: [CourseDetailsCellViewModel] = tabs.enumerated().map { index, tab in
            let selectionCallback: () -> Void = { [weak self] in
                guard let self = self else { return }
                // if home cell is shown we increase the cell index since the home cell is managed outside of this array
                self.selectionViewModel.cellTapped(at: index + (self.showHome ? 1 : 0))
            }
            return tab.toCellViewModel(attendanceToolID: attendanceToolID, course: course, cellSelectionAction: selectionCallback)
        }

        if permissions.first?.useStudentView == true {
            let studentViewCellModel = StudentViewCellViewModel(course: course)
            cellViewModels.append(studentViewCellModel)
        }

        updateCellSelectionStates(on: cellViewModels, selectedIndex: selectionViewModel.selectedIndex)
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

    @available(*, renamed: "refresh()")
    public func refresh(completion: @escaping () -> Void) {
        Task {
            await refresh()
            completion()
        }
    }

    public func refresh() async {
        requestAttendanceTool()
        permissions.refresh(force: true)
        colors.refresh(force: true)
        course.refresh(force: true)
        return await withCheckedContinuation { continuation in
            tabs.exhaust(force: true) { [weak self] _ in
                if self?.tabs.hasNextPage == false {
                    continuation.resume()
                }
                return true
            }
        }
    }
}
