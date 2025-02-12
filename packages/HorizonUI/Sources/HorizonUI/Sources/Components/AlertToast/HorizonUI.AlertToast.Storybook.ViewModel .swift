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

extension HorizonUI.AlertToast {
    @Observable
    final class StorybookViewModel {
        var toastViewModel = HorizonUI.AlertToast.ViewModel(text: "", style: .info)

        func showErrorToast() {
            toastViewModel = HorizonUI.AlertToast.ViewModel(
                text: "Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.",
                style: .error,
                isShowCancelButton: true,
                direction: .bottom,
                dismissAfter: 2,
                buttons: nil
            )
        }

        func showSuccessToast() {
            toastViewModel = HorizonUI.AlertToast.ViewModel(
                text: "Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.",
                style: .success,
                isShowCancelButton: true,
                direction: .top,
                buttons: .solid(title: "Yes Bro")
            )

            toastViewModel.onTapSolidButton = {
                print("onTapSolidButton")
            }
        }

        func showWarningToast() {
            toastViewModel = HorizonUI.AlertToast.ViewModel(
                text: "Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.",
                style: .warning,
                isShowCancelButton: false,
                direction: .bottom,
                dismissAfter: 15,
                buttons: .group(defaultTitle: "NO", solidTitle: "Thanks")
            )

            toastViewModel.onTapDefaultButton = {
                print("onTapDefaultButton")
            }

            toastViewModel.onTapSolidButton = {
                print("onTapSolidButton")
            }
        }

        func showInfoToast() {
            toastViewModel = HorizonUI.AlertToast.ViewModel(
                text: "Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.Nunc ut lacus ac libero ultrices vestibulum. Integer elementum.Nunc ut lacus ac libero ultrices vestibulum.",
                style: .info,
                isShowCancelButton: true,
                direction: .top
            )
        }
    }
}
