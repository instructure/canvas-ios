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
final class CourseDetailsViewModel: ProgramSwitcherMapper {
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
    private(set) var programs: [ProgramSwitcherModel] = []
    private(set) var selectedCoure: ProgramSwitcherModel.Course?
    private(set) var selectedProgram: ProgramSwitcherModel?
    private(set) var isLoaderVisible: Bool = false
    private(set) var overviewDescription = ""
    private(set) var scoresViewModel: ScoresViewModel?

    // MARK: - Inputs

    var onSelectCourse: (ProgramSwitcherModel.Course?) -> Void = { _ in }
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
    private let selectedTab: CourseDetailsTabs?
    private var pullToRefreshCancellable: AnyCancellable?
    private let scoresViewModelBuilder: ScoresViewModelBuilder

    // MARK: - Init

    /// The course parameter can be provided for immediate display. But doesn't have to be for flexibility, such as deep linking
    init(
        router: Router,
        getCoursesInteractor: GetCoursesInteractor,
        learnCoursesInteractor: GetLearnCoursesInteractor,
        programInteractor: ProgramInteractor,
        courseID: String,
        enrollmentID: String,
        programID: String?,
        course: HCourse?,
        selectedTab: CourseDetailsTabs? = nil,
        scoresViewModelBuilder: @escaping ScoresViewModelBuilder
    ) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor
        self.learnCoursesInteractor = learnCoursesInteractor
        self.programInteractor = programInteractor
        self.courseID = courseID
        self.course = course ?? .init()
        self.selectedProgram = .init(id: programID)
        self.isLoaderVisible = true
        self.selectedTab = selectedTab
        self.scoresViewModelBuilder = scoresViewModelBuilder
        fetchData()
        observeCourseSelection()
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

            pullToRefreshCancellable = coursePublisher
                .zip(syllabusPublisher)
                .sink { [weak self] course, syllabus in
                    continuation.resume()
                    guard let self = self, let course = course else { return }
                    self.course = course
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

    // MARK: - Private Functions

    private func observeCourseSelection() {
        onSelectCourse = { [weak self] selectedCourse in
            guard let self, let selectedCourse, self.selectedCoure != selectedCourse else {
                return
            }
            self.selectedProgram = selectedCourse.programID != nil ? programs.first(where: { $0.id == selectedCourse.programID }) : nil
            // Needs to cancel refresh api after change the course
            pullToRefreshCancellable?.cancel()
            pullToRefreshCancellable = nil
            isLoaderVisible = true
            self.selectedCoure = selectedCourse
            self.selectedTabIndex = nil
            getCourse(for: selectedCourse.id)
                .sink { [weak self] courseInfo in
                    self?.updateCourse(course: courseInfo.course, syllabus: courseInfo.syllabus)
                }
                .store(in: &subscriptions)
        }
    }

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
            getPrograms()
        )
        .sink { [weak self] courseInfo, courses, allPrograms in
            guard let self else { return }
            self.programs = mapPrograms(programs: allPrograms, courses: courses)
            selectedProgram = findProgram(containing: courseID, programID: selectedProgram?.id, in: allPrograms)
            updateCourse(course: courseInfo.course, syllabus: courseInfo.syllabus)
        }
        .store(in: &subscriptions)
    }

    private func getPrograms() -> AnyPublisher<[Program], Never> {
        programInteractor
            .getProgramsWithCourses(ignoreCache: false)
            .replaceError(with: [])
            .eraseToAnyPublisher()
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
        guard let course, (course.id == selectedCoure?.id || selectedCoure == nil ) else {
            return
        }
        self.course = course
        selectedCoure = .init(
            id: course.id,
            name: course.name,
            enrollemtID: course.enrollmentID,
            programID: selectedProgram?.id,
            programName: selectedProgram?.name
        )
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
