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

import SwiftUI

struct SnackBarViewModifier: ViewModifier {
    @ObservedObject var viewModel: SnackBarViewModel

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            ZStack(alignment: .bottom) {
                if let snack = viewModel.visibleSnack {
                    SnackBarView(text: snack)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onDisappear {
                            viewModel.snackDidDisappear()
                        }
                }
            }
            // iOS 15 disappear animation didn't play without this frame modifier
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .animation(.easeInOut(duration: viewModel.animationTime), value: viewModel.visibleSnack)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

public extension View {
    func snackBar(viewModel: SnackBarViewModel) -> some View {
        modifier(SnackBarViewModifier(viewModel: viewModel))
    }
}
