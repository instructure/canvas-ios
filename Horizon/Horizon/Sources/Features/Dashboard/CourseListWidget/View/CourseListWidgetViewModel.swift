//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import CombineSchedulers
import Core
import Foundation
import Observation

@Observable
class CourseListWidgetViewModel {
    enum ViewState {
        case data
        case empty
        case error
        case loading
    }

    // MARK: - Outputs

    private(set) var state: ViewState = .loading
    private(set) var courses: [HCourse] = []
    private(set) var unenrolledPrograms: [Program] = []
    var isProgramWidgetVisible: Bool {
        unenrolledPrograms.isNotEmpty && unenrolledPrograms.first?.id != "mock-program-id"
    }

    // MARK: - Dependencies

    private let courseListWidgetInteractor: CourseListWidgetInteractor
    private let programInteractor: ProgramInteractor
    private let router: Router
    private let onTapProgram: (ProgramSwitcherModel?, WeakViewController) -> Void
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Private variables

    private var getDashboardCoursesCancellable: AnyCancellable?
    private var refreshCompletedModuleItemCancellable: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        courseCardsInteractor: CourseListWidgetInteractor,
        programInteractor: ProgramInteractor,
        router: Router,
        onTapProgram: @escaping (ProgramSwitcherModel?, WeakViewController) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.courseListWidgetInteractor = courseCardsInteractor
        self.programInteractor = programInteractor
        self.router = router
        self.onTapProgram = onTapProgram
        self.scheduler = scheduler

        getCourses()
    }

    deinit {
        getDashboardCoursesCancellable?.cancel()
        getDashboardCoursesCancellable = nil
        refreshCompletedModuleItemCancellable?.cancel()
        refreshCompletedModuleItemCancellable = nil
    }

    private func getCourses(
        ignoreCache: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        state = .loading
        getDashboardCoursesCancellable?.cancel()
        refreshCompletedModuleItemCancellable?.cancel()

        getDashboardCoursesCancellable = courseListWidgetInteractor.getAndObserveCoursesWithoutModules(ignoreCache: ignoreCache)
            .prepend(Self.coursesMock) // Prepends a mock course object so skeleton loading is possible
            .combineLatest(
                programInteractor.getProgramsWithObserving(ignoreCache: ignoreCache).prepend(Self.programsMock)
            )
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        self?.state = .error
                    }
                },
                receiveValue: { [weak self] items, programs in
                    let courses = items.filter { $0.state == HCourse.EnrollmentState.active.rawValue }
                    let attachedCourses = self?.getAttachedPrograms(to: courses, from: programs) ?? []
                    let filteredPrograms = programs.filter { !$0.hasEnrolledCourse }

                    self?.courses = attachedCourses
                    self?.unenrolledPrograms = filteredPrograms

                    let invitedCourses = items.filter { $0.state == HCourse.EnrollmentState.invited.rawValue }
                    self?.acceptInvitation(courses: invitedCourses)

                    if attachedCourses.isEmpty {
                        self?.state = .empty
                    } else if let course = items.first, course.id != "mock-course-id" {
                        self?.state = .data
                    }

                    completion?()
                }
            )

        refreshCompletedModuleItemCancellable = courseListWidgetInteractor.refreshModuleItemsUponCompletions()
            .sink()
    }

    private func getAttachedPrograms(to hcourses: [HCourse], from programs: [Program]) -> [HCourse] {
        return hcourses.map { hcourse in
            var updateCourse = hcourse
            // Find all programs that contain this course id
            let matchedPrograms = programs.filter { program in
                program.courses.contains { $0.id == hcourse.id }
            }
            updateCourse.programs = matchedPrograms
            return updateCourse
        }
    }

    private func acceptInvitation(courses: [HCourse]) {
        Publishers.Sequence(sequence: courses)
            .flatMap { course in
                ReactiveStore(
                    useCase: HandleCourseInvitation(
                        courseID: course.id,
                        enrollmentID: course.enrollmentID,
                        isAccepted: true
                    )
                )
                .getEntities()
                .replaceError(with: [])
            }
            .collect()
            .sink()
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func reload(completion: (() -> Void)?) {
        getCourses(
            ignoreCache: true,
            completion: completion
        )
    }

    func navigateToItemSequence(
        url: URL,
        learningObject: HCourse.LearningObjectCard,
        viewController: WeakViewController
    ) {
        let moduleItem = HModuleItem(
            id: learningObject.learningObjectID,
            title: learningObject.learningObjectName,
            htmlURL: learningObject.url,
            /// `isCompleted` is set to `false` because this is the next module item
            /// the learner must complete. If it were `true`, it would no longer appear here.
            isCompleted: false
        )
        router.route(to: url, userInfo: ["moduleItem": moduleItem], from: viewController)
    }

    func navigateToCourseDetails(
        id: String,
        enrollmentID: String,
        programID: String?,
        viewController: WeakViewController
    ) {
        router.show(
            LearnAssembly.makeCourseDetailsViewController(
                courseID: id,
                enrollmentID: enrollmentID,
                programID: programID
            ),
            from: viewController
        )
    }

    func navigateProgram(id: String, viewController: WeakViewController) {
        onTapProgram(.init(id: id), viewController)
    }
}

extension CourseListWidgetViewModel {
    fileprivate static let coursesMock = [
        HCourse(
            id: "mock-course-id",
            name: "This is a mock course",
            state: HCourse.EnrollmentState.active.rawValue,
            currentLearningObject: .init(
                moduleTitle: "This is a mock module",
                learningObjectName: "Learning Object Name",
                learningObjectID: "1",
                type: .assessment,
                dueDate: "2025/12/31",
                url: nil,
                estimatedTime: "30 mins",
                isNewQuiz: false
            )
        )
    ]

    fileprivate static let programsMock = [
        Program(
            id: "mock-program-id",
            name: "This is a test program",
            variant: "",
            description: nil,
            date: "",
            courseCompletionCount: nil,
            courses: [ProgramCourse(id: "1", isSelfEnrolled: false, isRequired: false, status: "", progressID: "", completionPercent: 0)]
        )
    ]
}
