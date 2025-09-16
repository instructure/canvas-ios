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
final class LearnViewModel: ProgramSwitcherMapper {

    enum State {
        case programs
        case courseDetails
        case empty
    }
    // MARK: - Outputs (State)

    private(set) var state: State = .empty
    private(set) var courseDetailsViewModel: CourseDetailsViewModel?
    private(set) var isLoaderVisible = true
    private(set) var isLoadingEnrollButton = false
    private(set) var hasError = false
    private(set) var toastMessage = ""

    private(set) var programs: [Program] = []
    private(set) var currentProgram: Program?
    private(set) var selectedProgram: ProgramSwitcherModel?
    private(set) var dropdownMenuPrograms: [ProgramSwitcherModel] = []

    // MARK: - Inputs

    var onSelectProgram: (ProgramSwitcherModel?) -> Void = { _ in }

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
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init
    init(
        interactor: ProgramInteractor,
        learnCoursesInteractor: GetLearnCoursesInteractor,
        router: Router,
        programID: String? = nil,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.learnCoursesInteractor = learnCoursesInteractor
        self.router = router
        self.scheduler = scheduler
        selectedProgram = programID != nil  ? .init(id: programID) : nil
        configureSelectionHandler()
        featchPrograms()
    }

    private func configureSelectionHandler() {
        onSelectProgram = { [weak self] selectedProgram in
            guard let self, self.selectedProgram != selectedProgram else { return }
            self.selectedProgram = selectedProgram
            self.updateCurrentProgram(by: selectedProgram?.id)
        }
    }

    func updateProgram(_ program: ProgramSwitcherModel?) {
        selectedProgram = dropdownMenuPrograms.isEmpty ? program : dropdownMenuPrograms.first(where: { $0.id ==  program?.id })
        updateCurrentProgram(by: selectedProgram?.id)
        // We call fetchPrograms in case the learner has courses but no programs.
        // This handles the scenario when the learner pulls to refresh after enrolling
        // in a program, so they can see it immediately.
        if dropdownMenuPrograms.allSatisfy({ $0.id == nil }) {
            featchPrograms()
        }
    }

    func refreshPrograms() async {
        await fetchPrograms(ignoreCache: true)
    }

    func fetchPrograms(ignoreCache: Bool = false) async {
        await withCheckedContinuation { continuation in
            featchPrograms(ignoreCache: ignoreCache) {
                continuation.resume()
            }
        }
    }

    func featchPrograms(
        ignoreCache: Bool = false,
        completionHandler: (() -> Void)? = nil
    ) {
        interactor
            .getProgramsWithCourses(ignoreCache: ignoreCache)
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
            } receiveValue: { [weak self] programs, courses in
                self?.courses = courses
                self?.handleProgramsLoaded(programs)
                self?.dropdownMenuPrograms = self?.mapPrograms(programs: programs, courses: courses) ?? []
                self?.setState(programs: programs, courses: courses)
            }
            .store(in: &subscriptions)
    }

    private func setState(programs: [Program], courses: [LearnCourse]) {
        if programs.isNotEmpty {
            state = .programs
        } else if let firtCourse = courses.first {
            courseDetailsViewModel = LearnAssembly.makeViewModel(
                courseID: firtCourse.id,
                enrollmentID: firtCourse.enrollmentId
            )
            state = .courseDetails
        } else {
            state = .empty
        }
    }

    // MARK: - Actions

    func navigateToCourseDetails(
        courseID: String,
        programID: String? = nil,
        isEnrolled: Bool,
        viewController: WeakViewController
    ) {
        guard isEnrolled, let enrollemtID = courses.first(where: { $0.id == courseID })?.enrollmentId  else { return }
        router.show(
                LearnAssembly.makeCourseDetailsViewController(
                    courseID: courseID,
                    enrollmentID: enrollemtID,
                    programID: programID
                ),
                from: viewController
            )
    }

    func enrollInProgram(course: ProgramCourse) {
        isLoadingEnrollButton = true
        interactor.enrollInProgram(progressID: course.progressID)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.handleError(error)
            } receiveValue: { [weak self] programs in
                guard let self else { return }
                handleProgramsLoaded(programs)
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

    private func handleProgramsLoaded(_ programs: [Program]) {
        self.programs = programs

        if let first = programs.first {
            if selectedProgram == nil {
                currentProgram = applyIndexing(to: first)
                selectedProgram = mapProgram(program: first)
            } else if let existing = programs.first(where: { $0.id == selectedProgram?.id }) {
                currentProgram = applyIndexing(to: existing)
                selectedProgram = mapProgram(program: currentProgram)
            }
        }

        hasError = false
        isLoaderVisible = false
    }

    private func updateCurrentProgram(by id: String?) {
        guard let id, let program = programs.first(where: { $0.id == id }) else { return }
        currentProgram = applyIndexing(to: program)
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
