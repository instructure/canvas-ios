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
import Observation
import Foundation

@Observable
final class LearnViewModel {
    // MARK: - Outputs

    private(set) var isLoaderVisible: Bool = false
    private(set) var isLoadingEnrollButton = false
    private(set) var errorMessage = ""
    private(set) var courseDetailsViewModel: CourseDetailsViewModel?
    private(set) var programs: [ProgramCardModel] = []

    // MARK: - Input / Outputs

    var isAlertPresented = false

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let interactor: GetLearnCoursesInteractor

    // MARK: - Init

    init(interactor: GetLearnCoursesInteractor) {
        self.interactor = interactor
        getPrograms()
    }

    func fetchCourses(
        ignoreCache: Bool = false,
        isShowLoader: Bool = true,
        completionHandler: (() -> Void)? = nil
    ) {
        isLoaderVisible = isShowLoader
        interactor.getFirstCourse(ignoreCache: ignoreCache)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoaderVisible = false
                    completionHandler?()

                    if case .failure(let failure) = completion {
                        self?.errorMessage = failure.localizedDescription
                        self?.isAlertPresented = true
                    }
                },
                receiveValue: { [weak self] course in
                    guard let self, let course else {
                        return
                    }
                    courseDetailsViewModel = LearnAssembly.makeViewModel(
                        courseID: course.id,
                        enrollmentID: course.enrollmentId
                    )
                }
            )
            .store(in: &subscriptions)
    }

    func refreshCourses() async {
        await withCheckedContinuation { continuation in
            fetchCourses(ignoreCache: true, isShowLoader: false) {
                continuation.resume()
            }
        }
    }

   private func getPrograms() {
        var counter = 0
        let mocks = ProgramCardModel.mocks

        programs = mocks.map { program in
            var updatedProgram = program
            if program.isRequired {
                counter += 1
                updatedProgram.index = counter
            } else {
                updatedProgram.index = 0
            }
            return updatedProgram
        }
    }

    // MARK: - Output Functions

    func navigateToProgramDetails(programID: String) {

    }

    func enrollInProgram(programID: String) {
        isLoadingEnrollButton = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLoadingEnrollButton = false
        }
    }
}
