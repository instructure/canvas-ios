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
import SwiftUI

@Observable
class CourseCardsViewModel {
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

    // MARK: - Dependencies

    private let courseCardsInteractor: CourseCardsInteractor
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
        courseCardsInteractor: CourseCardsInteractor,
        programInteractor: ProgramInteractor,
        router: Router,
        onTapProgram: @escaping (ProgramSwitcherModel?, WeakViewController) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.courseCardsInteractor = courseCardsInteractor
        self.programInteractor = programInteractor
        self.router = router
        self.onTapProgram = onTapProgram
        self.scheduler = scheduler

        getCourses(ignoreCache: true)
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

        getDashboardCoursesCancellable = courseCardsInteractor.getAndObserveCoursesWithoutModules(ignoreCache: ignoreCache)
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
                    
                    if attachedCourses.isEmpty {
                        self?.state = .empty
                    } else if let course = items.first, course.id != "mock-course-id" {
                        self?.state = .data
                    }

                    completion?()
                }
            )

        refreshCompletedModuleItemCancellable = courseCardsInteractor.refreshModuleItemsUponCompletions()
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

//    func acceptInvitation(course: InvitedCourse) {
//        state = .loading
//        let useCase = HandleCourseInvitation(
//            courseID: course.id,
//            enrollmentID: course.enrollmentID,
//            isAccepted: true
//        )
//        ReactiveStore(useCase: useCase)
//            .getEntities()
//            .sink(receiveCompletion: { [weak self] completion in
//                if case let .failure(error) = completion {
//                    self?.state = .data
//                    self?.errorMessage = error.localizedDescription
//                    self?.isAlertPresented = true
//                }
//            }, receiveValue: { [weak self] _ in
//    //                self?.reload(completion: {})
//    //                self?.declineInvitation(course: course)
//            })
//            .store(in: &subscriptions)
//    }
}

extension CourseCardsViewModel {
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
            id: "1",
            name: "This is a test program",
            variant: "",
            description: nil,
            date: "",
            courseCompletionCount: nil,
            courses: [ProgramCourse(id: "1", isSelfEnrolled: false, isRequired: false, status: "", progressID: "", completionPercent: 0)]
        )
    ]
}
