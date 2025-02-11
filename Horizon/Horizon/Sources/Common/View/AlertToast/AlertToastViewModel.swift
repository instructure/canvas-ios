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

import HorizonUI
import Foundation
import CombineSchedulers
import Combine

final class AlertToastViewModel: ObservableObject {
    // MARK: - Output

    @Published private(set) var model: HorizonUI.AlertToast.Model?
    @Published private(set) var isShowToast = false

    private var scheduledDisappearance: Cancellable?
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.scheduler = scheduler
    }

    func show(alertModel: HorizonUI.AlertToast.Model) {
        model = alertModel
        isShowToast = true
        scheduledDisappearance = scheduler.schedule(
            after: scheduler.now.advanced(by: .init(floatLiteral: alertModel.dismissAfter)),
            interval: .zero
        ) { [weak self] in
            self?.dismiss()
        }
    }

    func dismiss() {
        model = nil
        isShowToast = false
        scheduledDisappearance = nil
    }
}
