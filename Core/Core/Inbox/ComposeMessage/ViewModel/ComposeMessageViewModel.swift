//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import CombineExt

class ComposeMessageViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var courses: [InboxCourse] = []
    @Published public var sendIndividual: Bool = false
    @Published public var bodyText: String = ""
    @Published public var subject: String = ""

    public let title = NSLocalizedString("New Message", bundle: .core, comment: "")

    // MARK: - Inputs
    public let sendButtonDidTap = PassthroughRelay<WeakViewController>()
    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let addRecipientButtonDidTap = PassthroughRelay<WeakViewController>()
    public var selectedCourse: InboxCourse?

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: ComposeMessageInteractor
    private let router: Router

    public init(router: Router, interactor: ComposeMessageInteractor) {
        self.interactor = interactor
        self.router = router

        setupOutputBindings()
        setupInputBindings(router: router)
    }

    public func courseSelectButtonDidTap(viewController: WeakViewController) {
        let options = courses
        var selected: IndexPath?
        if let selectedCourse = selectedCourse {
            selected = options.firstIndex(of: selectedCourse).flatMap {
                IndexPath(row: $0, section: 0)
            }
        }
        let sections = [ ItemPickerSection(items: options.map {
            ItemPickerItem(title: $0.name)
        }), ]

        router.show(ItemPickerViewController.create(
            title: NSLocalizedString("Select Course", comment: ""),
            sections: sections,
            selected: selected,
            didSelect: { self.selectedCourse = options[$0.row] }
        ), from: viewController)
    }

    public func addRecipientButtonDidTap(viewController: WeakViewController) {
        guard let courseID = selectedCourse?.courseId else { return }
        let addressbook = AddressBookAssembly.makeAddressbookViewController(courseID: courseID)
        router.show(addressbook, from: viewController)
    }

    private func setupOutputBindings() {
        interactor.state
                .assign(to: &$state)
        interactor.courses
            .assign(to: &$courses)
    }

    private func setupInputBindings(router: Router) {
        cancelButtonDidTap
            .sink { [router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }
}
