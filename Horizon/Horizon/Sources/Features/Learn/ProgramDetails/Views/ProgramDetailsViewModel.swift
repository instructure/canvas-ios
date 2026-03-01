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

import Core
import Combine
import CombineSchedulers
import Observation
import Foundation

@Observable
final class ProgramDetailsViewModel {
    // MARK: - Outputs (State)

    private(set) var isLoaderVisible = true
    private(set) var isLoadingEnrollButton = false
    private(set) var hasError = false
    private(set) var toastMessage = ""
    private(set) var currentProgram: Program?

    // MARK: - Inputs / Ouputs

    var toastIsPresented = false
    var shouldShowProgress: Bool {
        currentProgram?.isOptionalProgram == false
    }
    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private var courses: [LearnCourse] = []

    // MARK: - Dependencies

    private let interactor: ProgramInteractor
    private let learnCoursesInteractor: GetLearnCoursesInteractor
    private let router: Router
    private let programID: String
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init
    init(
        interactor: ProgramInteractor,
        learnCoursesInteractor: GetLearnCoursesInteractor,
        router: Router,
        programID: String,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.learnCoursesInteractor = learnCoursesInteractor
        self.router = router
        self.programID = programID
        self.scheduler = scheduler

        NotificationCenter.default.addObserver(
            forName: .moduleItemRequirementCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.fetchPrograms(ignoreCache: true)
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    func refreshPrograms() async {
        await fetchPrograms(ignoreCache: true)
    }

    func fetchPrograms(ignoreCache: Bool = false) async {
        await withCheckedContinuation { continuation in
            fetchPrograms(ignoreCache: ignoreCache) {
                continuation.resume()
            }
        }
    }

    func fetchPrograms(
        ignoreCache: Bool = false,
        completionHandler: (() -> Void)? = nil
    ) {
        let programID = self.programID
        interactor
            .getProgramsWithCourses(ignoreCache: ignoreCache)
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
            .first(where: { $0.id == programID })
            .zip(
                learnCoursesInteractor
                    .getCourses(ignoreCache: ignoreCache)
                    .setFailureType(to: Error.self)
            )
            .receive(on: scheduler)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
                completionHandler?()
            } receiveValue: { [weak self] program, courses in
                self?.courses = courses
                self?.handleProgramLoaded(program)
            }
            .store(in: &subscriptions)
    }

    // MARK: - Actions

    func navigateToCourseDetails(
        courseID: String,
        programName: String? = nil,
        isEnrolled: Bool,
        viewController: WeakViewController
    ) {
        guard isEnrolled, let enrollemtID = courses.first(where: { $0.id == courseID })?.enrollmentId  else { return }
        router.show(
            CourseDetailsAssembly.makeCourseDetailsViewController(
                    courseID: courseID,
                    enrollmentID: enrollemtID,
                    programName: programName
                ),
                from: viewController
            )
    }

    func enrollInProgram(course: ProgramCourse) {
        // Need to fetch learn courses again to get the updated enrollment IDs
        isLoadingEnrollButton = true
        interactor.enrollInProgram(progressID: course.progressID)
            .flatMap { [weak self] programs -> AnyPublisher<([Program], [LearnCourse]), Error> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.learnCoursesInteractor
                    .getCourses(ignoreCache: true)
                    .setFailureType(to: Error.self)
                    .map { courses in (programs, courses) }
                    .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.handleError(error)
            } receiveValue: { [weak self] programs, courses in
                guard let self else { return }
                self.courses = courses
                let programID = self.programID
                let program = programs.first(where: { $0.id == programID })
                handleProgramLoaded(program)
                let message = String(localized: "You’ve been enrolled in Course", bundle: .horizon)
                    .appending(" ")
                    .appending(course.name)
                self.showToast(message)
            }
            .store(in: &subscriptions)
    }

    func didTapBackButton(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    // MARK: - Helpers

    private func handleProgramLoaded(_ program: Program?) {
        guard let program else { return }
        currentProgram = applyIndexing(to: program)

        hasError = false
        isLoaderVisible = false
    }

    private func applyIndexing(to program: Program) -> Program {
        var program = program
        program.courses = program.courses.applyIndex()
        return program
    }

    private func handleError(_ error: Error) {
        hasError = true
        showToast(error.localizedDescription)
    }

    private func showToast(_ message: String) {
        isLoadingEnrollButton = false
        isLoaderVisible = false
        toastMessage = message
        toastIsPresented = true
    }
}
