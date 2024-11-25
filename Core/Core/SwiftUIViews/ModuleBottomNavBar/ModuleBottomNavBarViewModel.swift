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

final class ModuleBottomNavBarViewModel: ObservableObject {
    // MARK: - Dependencies

    private let router: Router
    private weak var hostingViewController: UIViewController?

    // These actions are triggered from UIKit ModuleItemSequenceViewController class.
    let didTapPreviousButton: () -> Void
    let didTapNextButton: () -> Void

    // MARK: - Outputs

    @Published var isPreviousButtonEnabled = true
    @Published var isNextButtonEnabled = true

    // MARK: - Init

    init(
        didTapPreviousButton: @escaping () -> Void,
        didTapNextButton: @escaping () -> Void,
        router: Router,
        hostingViewController: UIViewController?
    ) {
        self.didTapPreviousButton = didTapPreviousButton
        self.didTapNextButton = didTapNextButton
        self.router = router
        self.hostingViewController = hostingViewController
    }

    // MARK: - Inputs

    func didSelectButton(type _: ModuleNavBarButtons) {
        guard let hostingViewController else { return }
        router.route(to: "/tutor", from: hostingViewController, options: .modal())
    }
}
