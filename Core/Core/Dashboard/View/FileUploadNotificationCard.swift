//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct FileUploadNotificationCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Color.fire
                .overlay(
                    Image.share
                        .foregroundColor(Color.backgroundLightest)
                        .frame(width: 24, height: 24, alignment: .center)
                )
                .frame(width: 48, alignment: .center)
            VStack(spacing: 8) {
                Text("Uploading submission")
                    .font(.regular16)
                    .frame(alignment: .leading)
                ProgressView(value: 0.5)
                    .foregroundColor(Color(Brand.shared.primary))
                    .background(Color(Brand.shared.primary).opacity(0.2))
            }
            .padding(.top, 12)
            .padding(.bottom, 12)
            .padding(.trailing, 12)
        }
        .border(
            Color.fire,
            width: 2
        )
        .cornerRadius(4)
    }
}

struct FileUploadNotificationCard_Previews: PreviewProvider {
    static var previews: some View {
        FileUploadNotificationCard()
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
            .environment(\.sizeCategory, .extraSmall)
        FileUploadNotificationCard()
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
        FileUploadNotificationCard()
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        FileUploadNotificationCard()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
