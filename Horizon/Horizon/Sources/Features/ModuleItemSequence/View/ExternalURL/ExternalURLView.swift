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

import HorizonUI
import SwiftUI

struct ExternalURLView: View {

    let viewModel: ExternalURLViewModel

    init(viewModel: ExternalURLViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            VStack {
                HStack(spacing: HorizonUI.spaces.primitives.xSmall) {
                    Image.huiIcons.link
                        .foregroundColor(.huiColors.icon.default)

                    Text(viewModel.title)
                        .huiTypography(.p1)
                        .foregroundColor(.huiColors.text.body)

                    Spacer()

                    Image.huiIcons.openInNew
                        .foregroundColor(.huiColors.icon.default)
                }
                .padding(.all, .huiSpaces.primitives.medium)
            }
            .onTapGesture { viewModel.openURL() }
            .huiCornerRadius(level: .level3)
            .overlay {
                RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level3.attributes.radius)
                    .stroke(Color.huiColors.lineAndBorders.lineStroke, lineWidth: 1)
            }
            .padding(.all, .huiSpaces.primitives.medium)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ExternalURLView(
        viewModel: ExternalURLViewModel(
            title: "Instructure-Embedded",
            url: URL(string: "https://www.google.com")!
        )
    )
}
