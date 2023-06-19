//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct MessageDetailsView: View {
    @ObservedObject private var model: MessageDetailsViewModel
    @Environment(\.viewController) private var controller

    init(model: MessageDetailsViewModel) {
        self.model = model
    }

    public var body: some View {
        RefreshableScrollView {
            switch model.state {
            case .loading:
                loadingIndicator
            case .data:
                detailsView
            case .empty, .error:
                Text("There was an error loading the message. Pull to refresh to try again.", bundle: .core)
            }
        }
        refreshAction: { onComplete in
            model.refreshDidTrigger.send {
                onComplete()
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(model.title)
        .navigationBarItems(trailing: moreButton)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    private var detailsView: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            messageList
        }
    }

    private var headerView: some View {
        HStack {
            Text(model.subject)
                .font(.semibold22)
            Spacer()
            starButton
        }
    }

    private var moreButton: some View {
        Button(action: {
            model.moreTapped(viewController: controller)
        }, label: {
            Image
                .moreLine
                .foregroundColor(Color(Brand.shared.navTextColor))
        })
        .identifier("MessageDetails.moreButton")
        .accessibility(label: Text("More options", bundle: .core))
    }

    private var starButton: some View {
        Button(action: {
            model.starDidTap.send(!model.starred)
        }, label: {
            var star = Image.starLine
            var a11yLabel = NSLocalizedString("Un-starred", bundle: .core, comment: "")
            if model.starred {
                star = Image.starSolid
                a11yLabel = NSLocalizedString("Starred", bundle: .core, comment: "")
            }
            return star
                .size(30)
                .foregroundColor(.textDark)
                .padding(.leading, 6)
                .accessibilityLabel(a11yLabel)
        })
    }

    private var messageList: some View {
        ForEach(model.messages) { message in
            VStack(spacing: 0) {
                Color.borderMedium
                    .frame(height: 0.5)
                MessageView(model: message,
                            replyDidTap: { model.replyTapped(viewController: controller) },
                            moreDidTap: { model.moreTapped(viewController: controller) })
                .padding(16)

            }
        }
    }
}

#if DEBUG

struct MessageDetailsView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let body = """
        Lorem Ipsum is simply dummy text of the printing and typesetting industry.
        Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
        when an unknown printer took a galley of type and scrambled it to make a type specimen book.
        """
        MessageDetailsAssembly.makePreview(env: env, subject: "Message Title", messages: .make(count: 5, body: body, in: context))
    }
}

#endif
