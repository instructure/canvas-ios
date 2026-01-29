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

import Combine
import Core
import Foundation

@Observable
final class CourseDetailsViewModel {
    typealias ScoresViewModelBuilder = ((String, String) -> ScoresViewModel)

    // MARK: - Outputs

    private(set) var course: HCourse {
        didSet {
            if oldValue.id != course.id && course.id.isNotEmpty {
                scoresViewModel = scoresViewModelBuilder(course.id, course.enrollmentID)
            }
        }
    }
    private(set) var isShowHeader = true
    private(set) var courses: [LearnCourse] = []
    private(set) var courseTools: [ToolLinkItem] = []
    private(set) var isLoaderVisible: Bool = false
    private(set) var overviewDescription = ""
    private(set) var scoresViewModel: ScoresViewModel?

    // MARK: - Inputs

    private(set) var showHeaderPublisher = PassthroughSubject<Bool, Never>()

    // MARK: - Inputs / Outputs

    var selectedTabIndex: Int?

    // MARK: - Private

    private let router: Router
    private let courseID: String
    private var subscriptions = Set<AnyCancellable>()
    private let getCoursesInteractor: GetCoursesInteractor
    private let learnCoursesInteractor: GetLearnCoursesInteractor
    private let programInteractor: ProgramInteractor
    private let courseToolsInteractor: CourseToolsInteractor
    private let selectedTab: CourseDetailsTabs?
    private var pullToRefreshCancellable: AnyCancellable?
    private let scoresViewModelBuilder: ScoresViewModelBuilder
    let programName: String?

    // MARK: - Init

    /// The course parameter can be provided for immediate display. But doesn't have to be for flexibility, such as deep linking
    init(
        router: Router,
        getCoursesInteractor: GetCoursesInteractor,
        learnCoursesInteractor: GetLearnCoursesInteractor,
        programInteractor: ProgramInteractor,
        courseToolsInteractor: CourseToolsInteractor,
        courseID: String,
        enrollmentID: String,
        programName: String? = nil,
        course: HCourse?,
        selectedTab: CourseDetailsTabs? = nil,
        scoresViewModelBuilder: @escaping ScoresViewModelBuilder
    ) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor
        self.learnCoursesInteractor = learnCoursesInteractor
        self.programInteractor = programInteractor
        self.courseToolsInteractor = courseToolsInteractor
        self.courseID = courseID
        self.course = course ?? .init()
        self.isLoaderVisible = true
        self.selectedTab = selectedTab
        self.programName = programName
        self.scoresViewModelBuilder = scoresViewModelBuilder
        fetchData()
        observeHeaderVisiablity()
    }

    // MARK: - Inputs

    @MainActor
    func refresh() async {
        // Let other screens know about pull to refresh action
        NotificationCenter.default.post(name: .courseDetailsForceRefreshed, object: nil)

        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }
            let coursePublisher = getCoursesInteractor
                .getCourseWithModules(id: course.id, ignoreCache: true)
                .first()

            let syllabusPublisher = getCoursesInteractor
                .getCourseSyllabus(courseID: course.id, ignoreCache: true)
           let toolsPublisher = courseToolsInteractor.getTools(courseID: courseID, ignoreCache: true)

            pullToRefreshCancellable = Publishers.Zip3(coursePublisher, syllabusPublisher, toolsPublisher)
                .sink { [weak self] course, syllabus, tools in
                    continuation.resume()
                    guard let self = self, let course = course else { return }
                    self.course = course
                    self.courseTools = tools
                    self.overviewDescription = syllabus ?? ""
                }
        }
    }

    func didTapBackButton(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func moduleItemDidTap(item: HModuleItem, from: WeakViewController) {
        if let url = item.htmlURL {
            router.route(to: url, userInfo: ["moduleItem": item], from: from)
        }
    }

    func openSafari(url: URL, viewController: WeakViewController) {
        let tools = LTITools(
            context: nil,
            id: nil,
            url: url,
            isQuizLTI: false,
            assignmentID: nil,
            env: AppEnvironment.shared,
        )

        isLoaderVisible = true
        tools.getSessionlessLaunch { [weak self] value in
            guard let self, let url = value?.url  else {
                return
            }
            self.isLoaderVisible = false
            EmbeddedExternalTools.presentSafari(url: url, from: viewController, router: router)
        }
    }

    // MARK: - Private Functions

    private func observeHeaderVisiablity() {
        showHeaderPublisher
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isShowHeader = value
            }
            .store(in: &subscriptions)
    }

    private func fetchData() {
        Publishers.CombineLatest3(
            getCourse(for: courseID),
            getCourses(),
            courseToolsInteractor.getTools(courseID: courseID, ignoreCache: false)
        )
        .sink { [weak self] courseInfo, courses, tools in
            guard let self else { return }
            self.courses = courses
            self.courseTools = tools
            updateCourse(course: courseInfo.course, syllabus: courseInfo.syllabus)
        }
        .store(in: &subscriptions)
    }

    private func getCourses() -> AnyPublisher<[LearnCourse], Never> {
        learnCoursesInteractor
            .getCourses(ignoreCache: false)
            .flatMap { Publishers.Sequence(sequence: $0) }
            .collect()
            .eraseToAnyPublisher()
    }

    private func getCourse(for id: String) -> AnyPublisher<(course: HCourse?, syllabus: String?), Never> {
        // Should use CombineLatest instead of Zip to track changes to the course
        Publishers.CombineLatest(
            getCoursesInteractor.getCourseWithModules(id: id, ignoreCache: false),
            getCoursesInteractor.getCourseSyllabus(courseID: id, ignoreCache: false)
        )
        .map { (course: $0, syllabus: $1) }
        .eraseToAnyPublisher()
    }

    private func updateCourse(course: HCourse?, syllabus: String?) {
        guard let course else { return }
        self.course = course
        overviewDescription = syllabus ?? ""
        if selectedTabIndex == nil {
            selectedTabIndex = if let index = selectedTab?.rawValue {
                // We use index - 1 to designate the correctly selected tab.
                overviewDescription.isEmpty ? index - 1 : index
            } else {
                // Firt tab is 0 -> Overview 1 -> MyProgress
                overviewDescription.isEmpty ? 0 : 1
            }
        }
        isLoaderVisible = false
    }
}

extension Notification.Name {
    static let courseDetailsForceRefreshed = Notification.Name(rawValue: "com.instructure.horizon.course-details-refreshed")
}
