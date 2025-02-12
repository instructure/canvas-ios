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

extension HorizonUI.AlertToast {
    struct AlertToastModifier: ViewModifier {
        let viewModel: HorizonUI.AlertToast.ViewModel
        @Binding var isShowToast: Bool

        func body(content: Content) -> some View {
            content.overlay(alignment: viewModel.direction.alignment) {
                ZStack(alignment: .top) {
                    if  isShowToast {
                        HorizonUI.AlertToast(viewModel: viewModel) {
                            isShowToast = false
                        }
                        .transition(
                            .move(edge: viewModel.direction.edge)
                            .combined(with: .opacity)
                        )
                        .onAppear { dismissToast() }
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: viewModel.direction.alignment
                )
                .animation(.easeInOut(duration: 0.25), value: isShowToast)
            }
        }

        private func dismissToast() {
            DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.dismissAfter) {
                isShowToast = false
            }
        }
    }
}

extension View {
    public func alertToast(
        viewModel: HorizonUI.AlertToast.ViewModel,
        isShowToast: Binding<Bool>
    ) -> some View {
        modifier(HorizonUI.AlertToast.AlertToastModifier(viewModel: viewModel, isShowToast: isShowToast))
    }
}
