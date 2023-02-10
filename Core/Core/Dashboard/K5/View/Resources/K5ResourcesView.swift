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

public struct K5ResourcesView: View, ScreenViewTrackable {
    @Environment(\.horizontalPadding) private var horizontalPadding
    @ObservedObject public var viewModel: K5ResourcesViewModel
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/resources")

    public init(viewModel: K5ResourcesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        RefreshableScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                if !viewModel.homeroomInfos.isEmpty {
                    importantInfo
                }

                if !viewModel.applications.isEmpty {
                    applications
                }

                if !viewModel.contacts.isEmpty {
                    contacts
                }
            }
            .padding(.vertical)
        } refreshAction: { endRefreshing in
            viewModel.refresh(completion: endRefreshing)
        }
        .padding(.horizontal, horizontalPadding)
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    private var importantInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Important Info", bundle: .core)
                .foregroundColor(.textDarkest)
                .font(.bold20)
                .padding(.bottom)
                .accessibility(addTraits: .isHeader)
            ForEach(viewModel.homeroomInfos) { info in
                if viewModel.showInfoTitle {
                    HStack {
                        Image.coursesLine
                            .accessibility(hidden: true)
                        Text(info.homeroomName)
                            .foregroundColor(.textDarkest)
                            .font(.bold17)
                    }
                }
                WebView(html: info.htmlContent, canToggleTheme: true)
                    .frameToFit()
                    .padding(.horizontal, -16) // Removes padding in CSS

                if info != viewModel.homeroomInfos.last {
                    Divider().padding(.bottom)
                }
            }
        }
    }

    private var applications: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Student Applications", bundle: .core)
                .foregroundColor(.textDarkest)
                .font(.bold20)
                .padding(.bottom, 8)
                .accessibility(addTraits: .isHeader)

            ForEach(viewModel.applications) { application in
                K5ResourcesApplicationView(model: application)
            }
        }
    }

    private var contacts: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Staff Contact Info", bundle: .core)
                .foregroundColor(.textDarkest)
                .font(.bold20)
                .padding(.bottom, 8)
                .accessibility(addTraits: .isHeader)
            Divider()

            ForEach(viewModel.contacts) { contact in
                K5ResourcesContactInfoView(model: contact)
                Divider()
            }
        }
        .padding(.top, 27)
    }
}

#if DEBUG

struct K5ResourcesView_Previews: PreviewProvider {
    private static let env = AppEnvironment.shared
    private static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let courses = [
            APICourse.make(id: "1", name: "Homeroom 1", syllabus_body: "<h1>Infos</h1><p>This is a paragraph</p>", homeroom_course: true),
            APICourse.make(id: "2", name: "Homeroom 2", syllabus_body: "<b>IMPORTANT</b><p>Read the previous note</p>", homeroom_course: true),
        ]
        Course.save(courses, in: context)

        return K5ResourcesView(viewModel: K5ResourcesViewModel()).environment(\.horizontalPadding, 16)
    }
}

#endif
