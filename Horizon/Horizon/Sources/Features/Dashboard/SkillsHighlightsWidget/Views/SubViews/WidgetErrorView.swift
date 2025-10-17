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

struct WidgetErrorView: View {
    var onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text("We weren’t able to load this content. \n Please try again.")
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .frame(maxWidth: .infinity, alignment: .leading)

            HorizonUI.PrimaryButton(
                String(localized: "Refresh", bundle: .horizon),
                type: .grayOutline,
                isSmall: true,
                trailing: Image.huiIcons.restartAlt
            ) {
                onRetry()
            }
        }
    }
}

#Preview {
    WidgetErrorView(onRetry: {})
        .padding(.horizontal, 24)
}
