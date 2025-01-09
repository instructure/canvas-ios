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

public struct K5ResourcesContactInfoView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var viewController
    private let model: K5ResourcesContactViewModel

    public init(model: K5ResourcesContactViewModel) {
        self.model = model
    }

    public var body: some View {
        Button(action: {
            model.contactTapped(router: env.router, viewController: viewController)
        }, label: {
            HStack(spacing: 7) {
                Avatar(name: model.name, url: model.image, size: 48, isAccessible: false)
                    .padding(.vertical, 9)

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.name).font(.bold15)
                    Text(model.role).font(.regular13)
                }

                Spacer()
                Image.emailLine
            }
            .foregroundColor(.textDarkest)
        })
        .accessibility(label: Text(verbatim: "\(model.role), \(model.name)"))
        .accessibility(hint: Text("Send message", bundle: .core))
    }
}

#if DEBUG

struct K5ResourcesContactInfoView_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            K5ResourcesContactInfoView(model: K5ResourcesContactViewModel(image: nil, name: "Preview Teacher", role: "Teacher", userId: "1", courseContextID: "", courseName: ""))
            K5ResourcesContactInfoView(model: K5ResourcesContactViewModel(image: nil, name: "Preview TA", role: "Teacher's Assistant", userId: "1", courseContextID: "", courseName: ""))
        }.padding()
    }
}

#endif
