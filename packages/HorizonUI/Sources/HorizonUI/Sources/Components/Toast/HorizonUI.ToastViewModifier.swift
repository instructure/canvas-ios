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

extension HorizonUI.Toast {
    struct ToastViewModifier: ViewModifier {
        let viewModel: HorizonUI.Toast.ViewModel
        @Binding var isPresented: Bool

        func body(content: Content) -> some View {
            content.overlay(alignment: viewModel.direction.alignment) {
                ZStack(alignment: .top) {
                    if  isPresented {
                        HorizonUI.Toast(viewModel: viewModel) {
                            isPresented = false
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
                .animation(.easeInOut(duration: 0.25), value: isPresented)
            }
        }

        private func dismissToast() {
            DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.dismissAfter) {
                isPresented = false
            }
        }
    }
}

extension View {
    public func huiToast(
        viewModel: HorizonUI.Toast.ViewModel,
        isPresented: Binding<Bool>
    ) -> some View {
        modifier(HorizonUI.Toast.ToastViewModifier(viewModel: viewModel, isPresented: isPresented))
    }
}
