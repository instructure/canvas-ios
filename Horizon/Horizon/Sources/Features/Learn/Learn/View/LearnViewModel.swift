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
final class LearnViewModel {
    // MARK: - Outputs (State)

    private(set) var isLoaderVisible = true
    private(set) var isLoadingEnrollButton = false
    private(set) var hasError = false
    private(set) var toastMessage = ""

    private(set) var programs: [Program] = []
    private(set) var currentProgram: Program?
    private(set) var selectedProgram: DropdownMenuItem?
    private(set) var dropdownMenuPrograms: [DropdownMenuItem] = []

    // MARK: - Inputs

    var onSelectProgram: (DropdownMenuItem?) -> Void = { _ in }

    // MARK: - Inputs / Ouputs

    var toastIsPresented = false
    var shouldShowProgress: Bool {
        currentProgram?.isOptionalProgram == false
    }

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let interactor: ProgramInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init
    init(
        interactor: ProgramInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler
        configureSelectionHandler()
    }

    private func configureSelectionHandler() {
        onSelectProgram = { [weak self] selectedProgram in
            guard let self, self.selectedProgram != selectedProgram else { return }
            self.selectedProgram = selectedProgram
            self.updateCurrentProgram(by: selectedProgram?.id)
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
        interactor.getProgramsWithCourses(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.handleError(error)
                completionHandler?()
            } receiveValue: { [weak self] programs in
                guard let self else { return }
                self.handleProgramsLoaded(programs)
                completionHandler?()
            }
            .store(in: &subscriptions)
    }

    // MARK: - Actions

    func navigateToCourseDetails(course: ProgramCourse, viewController: WeakViewController) {
        guard let enrollemtID = course.enrollemtID else { return }
        router.show(
                LearnAssembly.makeCourseDetailsViewController(
                    courseID: course.id,
                    enrollmentID: enrollemtID
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

    // MARK: - Helpers

    private func handleProgramsLoaded(_ programs: [Program]) {
        self.programs = programs
        dropdownMenuPrograms = programs.map { .init(id: $0.id, name: $0.name) }

        if let first = programs.first {
            if currentProgram == nil {
                currentProgram = applyIndexing(to: first)
                selectedProgram = .init(id: first.id, name: first.name)
            } else if let existing = programs.first(where: { $0.id == currentProgram?.id }) {
                currentProgram = applyIndexing(to: existing)
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
