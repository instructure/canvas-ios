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
import UIKit

public class CalendarToDoDetailsViewModel: ObservableObject {

    // MARK: - Output

    public let navigationTitle = String(localized: "To Do", bundle: .core)
    public let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    @Published private(set) var state: InstUI.ScreenState = .data
    @Published public private(set) var title: String?
    @Published public private(set) var date: String?
    @Published public private(set) var description: String?
    @Published public private(set) var navBarColor: UIColor?
    @Published public var shouldShowDeleteConfirmation: Bool = false
    @Published public var shouldShowDeleteError: Bool = false

    var isMoreButtonEnabled: Bool {
        state == .data
    }

    public let deleteConfirmationAlert = ConfirmationAlertViewModel(
        title: String(localized: "Delete To Do?", bundle: .core),
        message: String(localized: "This will permanently delete your To Do item.", bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Delete", bundle: .core),
        isDestructive: true
    )

    // MARK: - Input

    let didTapEdit = PassthroughSubject<WeakViewController, Never>()
    let didTapDelete = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private

    private let plannableId: String
    private var plannable: Plannable?

    private let interactor: CalendarToDoInteractor
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(plannable: Plannable, interactor: CalendarToDoInteractor, router: Router) {
        self.plannableId = plannable.id
        self.plannable = plannable
        self.interactor = interactor
        self.router = router
        self.setupSubscriptions()
    }

    public init(plannableId: String, interactor: CalendarToDoInteractor, router: Router) {
        self.plannableId = plannableId
        self.interactor = interactor
        self.router = router
        self.setupSubscriptions()
    }

    private func setupSubscriptions() {
        interactor
            .getToDo(id: plannableId)
            .sink(
                receiveCompletion: { [weak self] in
                    guard let self else { return }

                    switch $0 {
                    case .finished:
                        break
                    case .failure:
                        if let plannable = self.plannable {
                            self.updateValues(with: plannable)
                        } else {
                            self.state = .error
                        }
                    }
                },
                receiveValue: { [weak self] in
                    self?.updateValues(with: $0)
                }
            )
            .store(in: &subscriptions)

        didTapEdit
            .sink { [weak self] in self?.showEditScreen(from: $0) }
            .store(in: &subscriptions)

        didTapDelete
            .map { [weak self] in
                self?.shouldShowDeleteConfirmation = true
                return $0
            }
            .flatMap { [deleteConfirmationAlert] in
                deleteConfirmationAlert.userConfirmation(value: $0)
            }
            .sink { [weak self] in self?.deleteToDo(from: $0) }
            .store(in: &subscriptions)
    }

    // MARK: - Private methods

    private func updateValues(with plannable: Plannable) {
        self.plannable = plannable

        title = plannable.title
        date = plannable.date?.dateTimeString
        description = plannable.details
        navBarColor = plannable.color.ensureContrast(against: .backgroundLightest)
    }

    private func showEditScreen(from source: WeakViewController) {
        guard let plannable else { return }

        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeEditToDoViewController(plannable: plannable) { [router] _ in
            router.dismiss(weakVC)
        }
        weakVC.setValue(vc)

        router.show(vc, from: source, options: .modal(isDismissable: false, embedInNav: true))
    }

    private func deleteToDo(from source: WeakViewController) {
        state = .data(loadingOverlay: true)

        interactor
            .deleteToDo(id: plannableId)
            .sink(
                receiveCompletion: { [weak self] in
                    switch $0 {
                    case .finished:
                        break
                    case .failure:
                        self?.state = .data
                        self?.shouldShowDeleteError = true
                    }
                },
                receiveValue: { [router] in
                    router.pop(from: source)
                }
            )
            .store(in: &subscriptions)
    }
}
