//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

/**
 This `UIActivityViewController` dismisses itself from presentation when the app moves to the background
 and if no other controllers are presented on top of it. This last check is to ensure we don't dismiss any file share extensions
 already on screen with user data entered.
 This was required to work around a crash affecting `UIActivityViewController` when the app moves to the background.
 */
public class CoreActivityViewController: UIActivityViewController {
    private var subscriptions = Set<AnyCancellable>()

    public override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.dismissSelfIfNothingIsPresented()
            }
            .store(in: &subscriptions)
    }

    private func dismissSelfIfNothingIsPresented() {
        guard presentedViewController == nil else { return }
        dismiss(animated: true)
    }
}
