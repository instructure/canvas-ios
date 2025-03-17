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

public struct K5ResourcesApplicationView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var viewController
    private let model: K5ResourcesApplicationViewModel
    @State private var isShowingSubjectPicker = false

    public init(model: K5ResourcesApplicationViewModel) {
        self.model = model
    }

    public var body: some View {
        Button(action: {
            isShowingSubjectPicker.toggle()
        },
        label: {
            HStack(spacing: 0) {
                if let imageURL = model.image {
                    RemoteImage(imageURL, width: 24, height: 24)
                } else {
                    Spacer().frame(width: 24, height: 24)
                }

                Text(model.name)
                    .foregroundColor(.textDarkest)
                    .font(.regular17)
                    .padding(.leading, 8)
                Spacer()
                InstUI.DisclosureIndicator().padding(.leading, 10)
            }
            .padding(.leading, 13)
            .padding(.trailing, 18)
            .frame(height: 51)
            .background(RoundedRectangle(cornerRadius: 4).stroke(Color.borderDark, lineWidth: 1 / UIScreen.main.scale))
            .background(Color.backgroundLightest)
            .cornerRadius(4)
            .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 2)
        })
        .accessibility(hint: Text("Open application", bundle: .core))
        .actionSheet(isPresented: $isShowingSubjectPicker) {
            ActionSheet(title: Text("Choose a subject", bundle: .core), buttons: subjectPickerButtons)
        }
    }

    private var subjectPickerButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = model.routesBySubjectNames.map { nameAndRoute in
            return ActionSheet.Button.default(Text(nameAndRoute.0)) {
                model.applicationTapped(router: env.router, route: nameAndRoute.1, viewController: viewController)
            }
        }
        buttons.append(.cancel(Text("Cancel", bundle: .core)))
        return buttons
    }
}

#if DEBUG

struct K5ResourcesApplicationView_Previews: PreviewProvider {

    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        VStack {
            K5ResourcesApplicationView(model:
                                        K5ResourcesApplicationViewModel(
                                            image: URL(string: "https://google-drive-lti-iad-prod.instructure.com/icon.png")!,
                                            name: "Google Drive",
                                            routesBySubjectNames: [("Math", URL(string: "https://instructure.com")!)]))
            K5ResourcesApplicationView(model:
                                        K5ResourcesApplicationViewModel(
                                            image: nil,
                                            name: "Google Drive Without Image",
                                            routesBySubjectNames: [("Art", URL(string: "https://instructure.com")!)]))
        }.padding(.horizontal)
    }
}

#endif
