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
import WidgetKit

struct GradeListFailureView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let iconName = "PandaUnsupported"
    private let title = String(localized: "Oops! Something Went Wrong")
    private let subtitle = String(localized: "We're having trouble showing your grades right now.  Please try again in a bit or head to the app.")

    var body: some View {
        VStack(spacing: family == .systemMedium ? 10 : 15) {
            Image(iconName, bundle: .core)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: family == .systemMedium ? 70 : 160)
                .accessibilityHidden(true)
            VStack(spacing: 5) {
                Text(title)
                    .font(.semibold14)
                    .foregroundStyle(Color.textDarkest)
                Text(subtitle)
                    .font(.regular12)
                    .foregroundStyle(Color.textDarkest)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Previews

#if DEBUG

#Preview("Medium", as: .systemMedium) {
    GradeListWidget()
} timeline: {
    GradeListWidgetEntry(data: GradeListModel(), date: Date())
}

#Preview("Large", as: .systemLarge) {
    GradeListWidget()
} timeline: {
    GradeListWidgetEntry(data: GradeListModel(), date: Date())
}

#endif
