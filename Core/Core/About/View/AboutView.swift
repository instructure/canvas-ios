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

public struct AboutView: View {
    @StateObject private var viewModel = AboutViewModel()
    @Environment(\.displayScale) private var scale: CGFloat

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.entries) { entry in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(entry.title)
                            .foregroundColor(.textDarkest)
                            .font(.semibold16, lineHeight: .fit)
                            .padding(.bottom, 2)
                        Text(entry.label)
                            .foregroundColor(.textDark)
                            .font(.regular14, lineHeight: .fit)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(entry.a11yLabel)
                    Color.borderMedium.frame(height: 1 / scale)
                }
                Image("instructure", bundle: .core)
                    .padding(.vertical, 36)
                    .accessibilityHidden(true)
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(viewModel.title)
    }
}

#if DEBUG

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

#endif
