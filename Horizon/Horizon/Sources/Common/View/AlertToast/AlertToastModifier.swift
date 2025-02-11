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

import SwiftUI
import HorizonUI

struct AlertToastModifier: ViewModifier {
    @ObservedObject var viewModel: AlertToastViewModel

    func body(content: Content) -> some View {
        content.overlay(alignment: viewModel.model?.direction.alignment ?? .bottom) {
            ZStack(alignment: .top) {
                if let model = viewModel.model {
                    HorizonUI.AlertToast(model: model) {
                        viewModel.dismiss()
                    }
                    .transition(
                        .move(edge: viewModel.model?.direction.edge ?? .bottom)
                        .combined(with: .opacity)
                    )
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: viewModel.model?.direction.alignment ?? .bottom
            )
            .animation(.easeInOut(duration: 0.25), value: viewModel.isShowToast)
        }
    }
}

extension View {
    func alertToast(viewModel: AlertToastViewModel) -> some View {
        modifier(AlertToastModifier(viewModel: viewModel))
    }
}
