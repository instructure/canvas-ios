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
import Core

struct DashboardWidgetErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        HStack(
            alignment: .top,
            spacing: InstUI.Styles.Padding.standard.rawValue
        ) {
            Image("PandaUnsupported", bundle: .core)
                .scaledIcon(size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text("Oops, Something went wrong", bundle: .student)
                    .font(.semibold16, lineHeight: .fit)
                    .foregroundStyle(.textDarkest)

                Text("We weren't able to load this content.\nTry again, or come back later.", bundle: .student)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundStyle(.textDark)
                    .paddingStyle(.bottom, .cellAccessoryPadding)

                Button(action: onRetry) {
                    HStack(spacing: 6) {
                        Text("Refresh", bundle: .student)
                            .font(.semibold14, lineHeight: .fit)
                        Image.refreshSolid
                            .scaledIcon(size: 16)
                    }
                    .foregroundStyle(.textLightest)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(Brand.shared.primary))
                    .clipShape(.rect(cornerRadius: 100))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .paddingStyle(set: .standardCell)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG

#Preview {
    DashboardWidgetErrorView(onRetry: {})
        .border(Color.black)
}

#endif
