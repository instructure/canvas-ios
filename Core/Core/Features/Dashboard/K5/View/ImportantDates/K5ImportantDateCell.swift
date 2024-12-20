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

struct K5ImportantDateCell: View {

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    var item: K5ImportantDateItem

    var body: some View {
        Button(action: {
            guard let route = item.route else { return }
            if UIDevice.current.userInterfaceIdiom == .pad {
                env.router.route(to: route, from: controller, options: .modal(isDismissable: false, embedInNav: true, addDoneButton: true))
            } else {
                env.router.route(to: route, from: controller, options: .detail)
            }
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(Color.borderMedium, lineWidth: 2).background(Color.backgroundLightest)
                HStack(spacing: 0) {
                    Rectangle().frame(width: 5).foregroundColor(item.color)
                    VStack(spacing: 2) {
                        subjectView
                        titleView
                    }
                }
            }.clipShape(
                RoundedRectangle(cornerRadius: 4)
            )
        }
        )
    }

    @ViewBuilder
    var subjectView: some View {
        HStack {
            Text(item.subject.uppercased())
                .font(.regular10)
                .foregroundColor(item.color)
                .padding(.top, 7)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer()
        }.padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 0))
    }

    @ViewBuilder
    var titleView: some View {
        HStack(alignment: .center, spacing: 0) {
            item.iconImage.foregroundColor(item.color).padding(EdgeInsets(top: 0, leading: 9, bottom: 0, trailing: 3))
            Text(item.title).font(.regular16).foregroundColor(.textDarkest).frame(maxWidth: .infinity, alignment: .leading).multilineTextAlignment(.leading)
            Spacer()
        }.padding(.bottom, 9)
    }
}

#if DEBUG

struct K5ImportantDatesCell_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        List {
            K5ImportantDateCell(item: K5ImportantDateItem(subject: "Math",
                                                          title: "This important date event title",
                                                          color: .red,
                                                          date: Date(),
                                                          route: nil,
                                                          type: .event))
            K5ImportantDateCell(item: K5ImportantDateItem(subject: "Supercalifragilisticexpialidociously long subject name",
                                                          title: "This way more longer than needed important date assignment title",
                                                          color: .blue,
                                                          date: Date(),
                                                          route: nil,
                                                          type: .assignment))
        }.environment(\.defaultMinListRowHeight, 10).previewLayout(.sizeThatFits)
    }
}

#endif
