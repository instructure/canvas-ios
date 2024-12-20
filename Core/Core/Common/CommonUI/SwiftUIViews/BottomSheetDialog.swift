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

import Foundation
import SwiftUI

struct BottomSheetDialog<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder let content: Content

    var body: some View {
        contentView
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            content
                .padding(20)
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(Color.backgroundLight)
        .cornerRadius(16)
    }
}

extension View {
    func bottomSheetDialog<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        ZStack {
            self
            VStack {
                Spacer()
                BottomSheetDialog(isPresented: isPresented) {
                    content()
                }
            }
            .background(Color.black.opacity(0.5))
        }
    }
}
