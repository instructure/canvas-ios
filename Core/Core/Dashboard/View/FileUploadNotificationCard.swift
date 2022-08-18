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
        HStack {
            VStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24, alignment: .center)
            }
            .padding(.leading, 16)
            VStack {
                Text("Uploading submission")
                ProgressView(value: 0.5)
                    .foregroundColor(Color(Brand.shared.primary))
                    .background(Color(Brand.shared.primary).opacity(0.2))
            }
            .padding(.top, 12)
            .padding(.bottom, 12)
            .padding(.leading, 16)
            .padding(.trailing, 12)
        }
        .border(
            Color(Brand.shared.color("fire")!),
            width: 2
        )
    }
}

struct FileUploadNotificationCard_Previews: PreviewProvider {
    static var previews: some View {
        FileUploadNotificationCard()
            .previewLayout(.sizeThatFits)
    }
}
