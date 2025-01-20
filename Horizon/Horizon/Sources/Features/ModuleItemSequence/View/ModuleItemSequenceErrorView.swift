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
import HorizonUI

struct ModuleItemSequenceErrorView: View {

    // MARK: - Dependencies

    private let didTapRetry: () -> Void

    init(didTapRetry: @escaping () -> Void) {
        self.didTapRetry = didTapRetry
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image.huiIcons.error
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color.huiColors.icon.error)

            Text("There was an error. please try again.", bundle: .horizon)
                .foregroundStyle(Color.huiColors.primitives.grey45)
                .huiTypography(.h3)

            Button {
                didTapRetry()
            } label: {
                retryButtonLabel
            }
            Spacer()
        }
    }

    private var retryButtonLabel: some View {
        Text("Retry", bundle: .horizon)
            .foregroundStyle(Color.huiColors.primitives.grey24)
            .huiTypography(.labelLargeBold)
            .padding(.huiSpaces.primitives.smallMedium)
            .frame(width: 120, height: 55)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.huiColors.primitives.grey24, lineWidth: 2)
            )
    }
}

#Preview {
    ModuleItemSequenceErrorView {}
}
