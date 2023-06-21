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

class ComposeMessageViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public var sendIndividual: Bool = false
    @Published public var bodyText: String = ""
    @Published public var subject: String = ""

    public let title = NSLocalizedString("New Message", bundle: .core, comment: "")

    // MARK: - Inputs
    public let sendDidTap = PassthroughSubject<Void, Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: ComposeMessageInteractor
    private let router: Router

    public init(router: Router, interactor: ComposeMessageInteractor) {
        self.interactor = interactor
        self.router = router

        // setupOutputBindings()
        // setupInputBindings(router: router)
    }
}
