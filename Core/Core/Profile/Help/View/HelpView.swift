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

struct HelpView: View, ScreenViewTrackable {
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/profile/help")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(helpLinks, id: \.self) {
                    HelpItemView(model: $0, tapAction: tapAction)
                    Divider()
                }
            }.padding(.bottom)
        }
        .accessibilityIdentifier("helpItems")
    }

    private var helpLinks: [HelpLink]
    private let tapAction: (HelpLink) -> Void

    init(helpLinks: [HelpLink], tapAction: @escaping (HelpLink) -> Void) {
        self.helpLinks = helpLinks
        self.tapAction = tapAction
    }
}

#if DEBUG
struct HelpViewPreviews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let item0 = HelpLink(context: context)
        item0.text = "Search the Canvas Guides"
        item0.subtext = "Find answers to common questions"
        let item1 = HelpLink(context: context)
        item1.text = "Ask Your Instructor a Question"
        item1.subtext = "Questions are submitted to your instructor"
        let item2 = HelpLink(context: context)
        item2.text = "Report a Problem"
        item2.subtext = "If Canvas misbehaves, tell us about it"
        let item3 = HelpLink(context: context)
        item3.text = "COVID-19 Canvas Resources"
        item3.subtext = "Tips for teaching and learning online"
        let item4 = HelpLink(context: context)
        item4.text = "Video Conferencing Guides for Remote Classrooms"
        item4.subtext = "Get help on how to use and configure conferences in canvas."
        let item5 = HelpLink(context: context)
        item5.text = "Submit a Feature Idea"
        item5.subtext = "Have an idea to improve Canvas?"

        return HelpView(helpLinks: [item0, item1, item2, item3, item4, item5], tapAction: { _ in }).previewLayout(.sizeThatFits)
    }
}
#endif
