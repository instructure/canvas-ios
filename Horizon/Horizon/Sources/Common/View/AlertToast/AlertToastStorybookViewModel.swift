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
import Observation
import HorizonUI

@Observable
final class AlertToastStorybookViewModel {
    private(set) var alertToastViewModel = AlertToastViewModel()

    func showErrorToast() {
        let model = HorizonUI.AlertToast.Model(
            text: "Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.",
            style: .error,
            isShowCancelButton: true,
            direction: .bottom,
            dismissAfter: 2,
            buttons: nil
        )

        alertToastViewModel.show(alertModel: model)
    }

    func showSuccessToast() {
        var model = HorizonUI.AlertToast.Model(
            text: "Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.",
            style: .success,
            isShowCancelButton: true,
            direction: .top,
            buttons: .solid(title: "Yes Bro")
        )

        model.onTapSolidButton = {
            print("onTapSolidButton")
        }

        alertToastViewModel.show(alertModel: model)
    }

    func showWarningToast() {
        var model = HorizonUI.AlertToast.Model(
            text: "Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.",
            style: .warning,
            isShowCancelButton: false,
            direction: .bottom,
            dismissAfter: 5,
            buttons: .group(defaultTitle: "NO", solidTitle: "Thanks")
        )

        model.onTapDefaultButton = {
            print("onTapDefaultButton")
        }

        model.onTapSolidButton = {
            print("onTapSolidButton")
        }

        alertToastViewModel.show(alertModel: model)
    }

    func showInfoToast() {
        let model = HorizonUI.AlertToast.Model(
            text: "Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.Nunc ut lacus ac libero ultrices vestibulum.",
            style: .info,
            isShowCancelButton: true,
            direction: .top
        )

        alertToastViewModel.show(alertModel: model)
    }
}
