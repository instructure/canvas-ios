//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct K5HomeroomAnnouncementView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    private let viewModel: K5HomeroomAnnouncementViewModel

    init(viewModel: K5HomeroomAnnouncementViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.courseName)
                .foregroundColor(.ash)
                .font(.regular14)
            Text(viewModel.title)
                .foregroundColor(.licorice)
                .font(.regular24)
            WebView(html: viewModel.htmlContent)
                .frameToFit()
                // Offset default CSS padding in CoreWebView
                .padding(.horizontal, -16)
                .padding(.top, -10)
            Button(action: openPreviousAnnouncements, label: {
                Text("View Previous Announcements", bundle: .core)
                    .font(.regular16)
                    .foregroundColor(Color(Brand.shared.primary))
            })
        }
    }

    private func openPreviousAnnouncements() {
        env.router.route(to: viewModel.allAnnouncementsRoute, from: controller)
    }
}

struct K5HomeRoomAnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        let model = K5HomeroomAnnouncementViewModel(courseName: "K5 - Math", title: "New Assignment!", htmlContent: "<h1>Make sure to complete in time!</h1>", allAnnouncementsRoute: "")
        K5HomeroomAnnouncementView(viewModel: model).previewLayout(.sizeThatFits)
    }
}
