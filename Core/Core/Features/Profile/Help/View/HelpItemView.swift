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

struct HelpItemView: View {
    var body: some View {
        Button(action: {
            tapAction(model)
        }, label: {
            VStack(alignment: .leading, spacing: 5) {
                Text(model.text ?? "")
                    .font(.semibold16)
                    .foregroundColor(.textDarkest)
                    .testID()
                    .fixedSize(horizontal: false, vertical: true) // iOS 13.0 multi line support
                    .multilineTextAlignment(.leading)
                if let subtext = model.subtext {
                    Text(subtext)
                        .font(.regular16)
                        .foregroundColor(.textDark)
                        .testID()
                        .fixedSize(horizontal: false, vertical: true) // iOS 13.0 multi line support
                        .multilineTextAlignment(.leading)
                }
            }.frame(maxWidth: .infinity, alignment: .leading).padding(EdgeInsets(top: 15, leading: 16, bottom: 14, trailing: 16))
                .contentShape(Rectangle())
        })
        .frame(maxWidth: .infinity)
        .background(Color.backgroundLightest)
        .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
        .testID(.cell)
    }
    private let model: HelpLink
    private let tapAction: (HelpLink) -> Void

    init(model: HelpLink, tapAction: @escaping (HelpLink) -> Void) {
        self.model = model
        self.tapAction = tapAction
    }
}

#if DEBUG
struct HelpItemViewPreviews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let item = HelpLink(context: context)
        item.text = "Video Conferencing Guides for Remote Classrooms in Remote Locations"
        item.subtext = "Find answers to common questions"
        return HelpItemView(model: item, tapAction: { _ in }).previewLayout(.sizeThatFits)
    }
}
#endif
