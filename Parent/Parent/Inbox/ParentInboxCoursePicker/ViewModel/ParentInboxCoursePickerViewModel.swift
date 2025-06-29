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

import Foundation
import Combine
import CombineExt
import Core

public class ParentInboxCoursePickerViewModel: ObservableObject {
    // MARK: - Output
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var items: [StudentContextItem] = []
    @Published public private(set) var isDarkInterface: Bool

    // MARK: - Inputs
    public let didTapContext = PassthroughRelay<(WeakViewController, StudentContextItem)>()
    public let didTapRefresh = PassthroughRelay<Void>()

    // MARK: - Private
    private let interactor: ParentInboxCoursePickerInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router
    private let environemnt: AppEnvironment

    init(interactor: ParentInboxCoursePickerInteractor, environment: AppEnvironment, router: Router) {
        self.interactor = interactor
        self.router = router
        self.environemnt = environment
        self.isDarkInterface = environment.userDefaults?.interfaceStyle == .dark
        setupOutputBindings()
        setupInputBindings()
    }

    private func setupOutputBindings() {
        interactor.state
            .assign(to: &$state)
        interactor.studentContextItems
            .assign(to: &$items)
    }

    private func setupInputBindings() {
        didTapContext
            .sink { [weak self] (controller, context) in
                guard let self else { return }
                let options = self.routeToCompose(controller, context)
                let parent = controller.value.presentingViewController
                router.dismiss(controller) {
                    self.router.show(
                        ComposeMessageAssembly.makeComposeMessageViewController(env: self.environemnt, options: options),
                        from: parent ?? controller.value,
                        options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true)
                    )
                }
            }
            .store(in: &subscriptions)

        didTapRefresh
            .sink { [weak self] in
                _ = self?.interactor.refresh()
            }
            .store(in: &subscriptions)
    }

    private func routeToCompose(_ controller: WeakViewController, _ selectedContext: StudentContextItem) -> ComposeMessageOptions {
        let hiddenMessage = String(localized: "Regarding: \(selectedContext.studentDisplayName), \(interactor.getCourseURL(courseId: selectedContext.course.id))", bundle: .core)
        return ComposeMessageOptions(
            disabledFields: DisabledMessageFieldOptions(
                contextDisabled: true
            ),
            fieldsContents: DefaultMessageFieldContents(
                selectedContext: RecipientContext(name: selectedContext.course.name ?? "", context: Context(.course, id: selectedContext.course.id)),
                subjectText: selectedContext.course.name ?? ""
            ),
            messageType: .new,
            extras: ExtraMessageOptions(
                hiddenMessage: hiddenMessage,
                autoTeacherSelect: true
            )
        )
    }
}
