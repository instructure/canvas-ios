//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import SwiftUI

struct EnrollConfirmationView: View {
    @Binding private var isPresented: Bool
    private let isLoading: Bool
    private let onTap: () -> Void

    init( isPresented: Binding<Bool>, isLoading: Bool, onTap: @escaping () -> Void) {
        self.isLoading = isLoading
        self.onTap = onTap
        self._isPresented = isPresented
    }

    var body: some View {
        ZStack {
            Color.huiColors.surface.inverseSecondary.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented.toggle()
                }
            contentView
                .padding(.horizontal, .huiSpaces.space24)
                .scaleEffect(isPresented ? 1 : 0.6)
        }
        .opacity(isPresented ? 1 : 0)
        .animation(.spring, value: isPresented)
    }

    private var contentView: some View {
        VStack(spacing: .huiSpaces.space16) {
            headerView
            Text("Enroll to access the course and start learning")
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
                .padding(.horizontal, .huiSpaces.space16)
                .padding(.vertical, .huiSpaces.space10)
            footer
        }
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level4)
    }

    private var headerView: some View {
        VStack(spacing: .huiSpaces.space16) {
            HStack {
                Text("Ready to join?")
                    .huiTypography(.h3)
                    .foregroundStyle(Color.huiColors.text.title)
                Spacer()
                HorizonUI.IconButton(Image.huiIcons.close, type: .gray) {
                    isPresented.toggle()
                }
                .padding(.trailing, .huiSpaces.space8)
            }
            .padding(.leading, .huiSpaces.space16)
            .padding(.top, .huiSpaces.space24)
            lineView
        }
    }

    private var footer: some View {
       VStack {
           lineView
            HStack {
                Spacer()
                HorizonUI.LoadingButton(
                        title: String(localized: "Enroll"),
                        type: .black,
                        fillsWidth: false,
                        isLoading: isLoading
                    ) {
                        onTap()
                }
                .padding(.bottom, .huiSpaces.space24)
                .padding(.horizontal, .huiSpaces.space16)
                .padding(.top, .huiSpaces.space12)
            }
        }
    }

    private var lineView: some View {
        Rectangle()
            .fill(Color.huiColors.lineAndBorders.lineDivider)
            .frame(height: 1)
    }
}

#Preview {
    EnrollConfirmationView(isPresented: .constant(true), isLoading: false) {}
}
