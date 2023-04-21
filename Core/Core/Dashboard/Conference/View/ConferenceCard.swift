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

struct ConferenceCard: View {
    @ObservedObject var conference: Conference
    let contextName: String

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Image.infoSolid.foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.top, 10)
                Spacer()
            }
                .background(Color.backgroundInfo)
                .onTapGesture(perform: join)
            Button(action: join, label: {
                VStack(alignment: .leading, spacing: 0) {
                    HStack { Spacer() }
                    Text("Conference in progress", bundle: .core)
                        .font(.semibold16).foregroundColor(.textDarkest)
                    Text(contextName)
                        .font(.regular14).foregroundColor(.textDark)
                }
                    .padding(.horizontal, 16).padding(.vertical, 12)
            })
                .accessibility(label: Text("Conference \(conference.title) is in progress, tap to view details", bundle: .core))
                .identifier("LiveConference.\(conference.id).navigateButton")
            Button(action: dismiss, label: {
                Image.xSolid.foregroundColor(.textDark)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
            })
                .accessibility(label: Text("Dismiss \(conference.title)", bundle: .core))
                .identifier("LiveConference.\(conference.id).dismissButton")
        }
            .background(RoundedRectangle(cornerRadius: 4).stroke(Color.backgroundInfo))
            .background(Color.backgroundLightest)
            .cornerRadius(4)
    }

    func join() {
        env.router.route(to: "\(conference.context.pathComponent)/conferences/\(conference.id)/join", from: controller, options: .modal())
    }

    func dismiss() {
        let id = conference.id
        env.database.performWriteTask { context in
            let model: Conference? = context.first(where: #keyPath(Conference.id), equals: id)
            model?.isIgnored = true
            try? context.save()
        }
    }
}
