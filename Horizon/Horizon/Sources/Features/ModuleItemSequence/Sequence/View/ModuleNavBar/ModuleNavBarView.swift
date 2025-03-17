//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core
import HorizonUI

struct ModuleNavBarView: View {
    struct ButtonAttribute {
        let isVisible: Bool
        let action: () -> Void

        init(isVisible: Bool, action: @escaping () -> Void) {
            self.isVisible = isVisible
            self.action = action
        }

    }
    // MARK: - Private Properties

    @Environment(\.viewController) private var controller

    // MARK: - Dependencies

    private let router: Router
    private let nextButton: ModuleNavBarView.ButtonAttribute
    private let previousButton: ModuleNavBarView.ButtonAttribute
    private let assignmentMoreOptionsButton: ModuleNavBarView.ButtonAttribute?
    private let visibleButtons: [ModuleNavBarUtilityButtons]

    init(
        router: Router,
        nextButton: ModuleNavBarView.ButtonAttribute,
        previousButton: ModuleNavBarView.ButtonAttribute,
        assignmentMoreOptionsButton: ModuleNavBarView.ButtonAttribute? = nil,
        visibleButtons: [ModuleNavBarUtilityButtons]
    ) {
        self.router = router
        self.nextButton = nextButton
        self.previousButton = previousButton
        self.assignmentMoreOptionsButton = assignmentMoreOptionsButton
        self.visibleButtons = visibleButtons
    }

    var body: some View {
        HStack(spacing: .zero) {
            previousButtonView

            Spacer()
            HStack(spacing: .huiSpaces.space8) {
                ForEach(visibleButtons, id: \.self) { button in
                    switch button {
                    case .tts:
                        buttonView(type: .tts) {}
                    case .chatBot(let courseId, let pageUrl, let fileId):
                        chatBotButton(courseId: courseId, pageUrl: pageUrl, fileId: fileId)
                    case .notebook:
                        buttonView(type: .notebook) {
                            router.route(to: "/notebook", from: controller)
                        }
                    case .assignmentMoreOptions:
                        assignmentMoreOptionsButtonView
                    }
                }
            }
            Spacer()
            nextButtonView
        }
    }

    private var previousButtonView: some View {
        HorizonUI.IconButton(
            ModuleNavBarButtons.previous.image,
            type: .white
        ) {
            previousButton.action()
        }
        .huiElevation(level: .level2)
        .hidden(!previousButton.isVisible)
    }

    @ViewBuilder
    private var assignmentMoreOptionsButtonView: some View {
        if let assignmentMoreOptionsButton {
            HorizonUI.IconButton(
                ModuleNavBarUtilityButtons.assignmentMoreOptions.image,
                type: .white
            ) {
                assignmentMoreOptionsButton.action()
            }
            .huiElevation(level: .level2)
            .hidden(!assignmentMoreOptionsButton.isVisible)
        }
    }

    private var nextButtonView: some View {
        HorizonUI.IconButton(
            ModuleNavBarButtons.next.image,
            type: .white
        ) {
            nextButton.action()
        }
        .huiElevation(level: .level2)
        .hidden(!nextButton.isVisible)
    }

    private func buttonView(type: ModuleNavBarUtilityButtons, onTap: @escaping (() -> Void)) -> some View {
        HorizonUI.IconButton(
            type.image,
            type: .white,
            action: onTap
        )
        .huiElevation(level: .level2)
    }

    private func chatBotButton(
        courseId: String? = nil,
        pageUrl: String? = nil,
        fileId: String? = nil
    ) -> some View {
        Button {
            navigateToTutor(courseId: courseId, pageUrl: pageUrl, fileId: fileId)
        } label: {
            ModuleNavBarUtilityButtons.chatBot().image
                .resizable()
                .frame(width: 44, height: 44)
                .huiElevation(level: .level2)
        }
    }

    private func navigateToTutor(courseId: String? = nil, pageUrl: String? = nil, fileId: String? = nil) {
        let params = [
            "courseId": courseId,
            "pageUrl": pageUrl,
            "fileId": fileId
        ].map { key, value in
            guard let value = value else { return nil }
            return "\(key)=\(value)"
        }.compactMap { $0 }.joined(separator: "&")
        router.route(to: "/assistant?\(params)", from: controller, options: .modal())
    }
}
