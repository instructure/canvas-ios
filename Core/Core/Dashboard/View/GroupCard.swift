//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct GroupCard: View {
    @ObservedObject var group: Group
    let course: Course?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            env.router.route(to: "/groups/\(group.id)", from: controller)
        }, label: {
            HStack(spacing: 0) {
                Rectangle().fill(Color.accentColor).frame(width: 4)
                VStack(alignment: .leading, spacing: 0) {
                    HStack { Spacer() }
                    Text(group.name)
                        .font(.semibold18).foregroundColor(.textDarkest)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                    Text(course?.name ?? NSLocalizedString("Account Group", comment: ""))
                        .font(.semibold16).foregroundColor(.accentColor)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                    course?.termName.map { Text($0.localizedUppercase) }
                        .font(.semibold12).foregroundColor(.textDark)
                    Spacer()
                }
                    .padding(8)
            }
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color(white: 0.89), lineWidth: 1 / UIScreen.main.scale))
                .background(colorScheme == .light ? Color.white : Color.black)
                .cornerRadius(4)
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
        })
            .buttonStyle(ScaleButtonStyle(scale: 1))
            .identifier("group-row-\(group.id)")
    }
}
