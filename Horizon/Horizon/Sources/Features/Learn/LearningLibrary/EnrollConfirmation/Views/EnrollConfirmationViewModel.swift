//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Foundation
import Observation

@Observable
final class EnrollConfirmationViewModel {
    // MARK: - Outputs

    private(set) var isEnrollLoaderVisible: Bool = false
    private(set) var isLoaderVisible: Bool = true
    private(set) var overView: String?
    private(set) var errorMessage = ""

    // MARK: - Inputs / Outputs

    var isErrorVisible: Bool = false

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let model: LearningLibraryCardModel
    private let interactor: LearningLibraryInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let onTap: (LearningLibraryCardModel) -> Void

    // MARK: - Init

    init(
        model: LearningLibraryCardModel,
        router: Router,
        interactor: LearningLibraryInteractor = LearningLibraryInteractorLive(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        onTap: @escaping (LearningLibraryCardModel) -> Void
    ) {
        self.onTap = onTap
        self.interactor = interactor
        self.scheduler = scheduler
        self.router = router
        self.model = model
        getCourseSyllabus()
    }

    private func getCourseSyllabus() {
        ReactiveStore(useCase: GetCourse(courseID: model.itemId))
            .getEntities()
            .receive(on: scheduler)
            .replaceError(with: [])
            .map { $0.first?.syllabusBody }
            .sink { [weak self] syllabus in
                self?.overView = syllabus
                self?.isLoaderVisible = false
            }
            .store(in: &subscriptions)
    }

     func enroll(viewController: WeakViewController) {
         isEnrollLoaderVisible = true
         interactor.enroll(id: model.id, itemID: model.itemId)
             .receive(on: scheduler)
             .sinkFailureOrValue { [weak self] error in
                 guard let self else { return }
                 self.errorMessage = error.localizedDescription
                 self.isErrorVisible = true
                 isEnrollLoaderVisible = false
             } receiveValue: { [weak self] item in
                 guard let self else { return }
                 isEnrollLoaderVisible = false
                 dismiss(viewController: viewController) { [weak self] in
                     self?.onTap(item)
                 }
             }
             .store(in: &subscriptions)
     }

    func dismiss(viewController: WeakViewController, completion: (() -> Void)? = nil) {
        router.dismiss(viewController, completion: completion)
    }
}
