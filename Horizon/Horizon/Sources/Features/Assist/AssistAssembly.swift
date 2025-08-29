//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import UIKit
import SwiftUI
import Core

final class AssistAssembly {

    static func makeAssistChatView(
        courseID: String? = nil,
        pageURL: String? = nil,
        fileID: String? = nil,
        textSelection: String? = nil
    ) -> UINavigationController {
        let viewModel = AssistChatViewModel(
            courseID: courseID,
            pageURL: pageURL,
            fileID: fileID,
            assistChatInteractor: makeChatBotInteractor(
                courseID: courseID,
                pageURL: pageURL,
                fileID: fileID,
                textSelection: textSelection
            )
        )
        let view = AssistChatView(viewModel: viewModel)
        let viewController = CoreHostingController(view)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }

    static func makeChatBotInteractor(
        courseID: String? = nil,
        pageURL: String? = nil,
        fileID: String? = nil,
        textSelection: String? = nil
    ) -> AssistChatInteractor {
        AssistChatInteractorLive(
            courseID: courseID,
            pageID: pageURL,
            fileID: fileID,
            textSelection: textSelection
        )
    }

    static func makeAIQuizView(
        courseID: String? = nil,
        fileID: String? = nil,
        pageURL: String? = nil,
        quizzes: [AssistQuizModel] = []
    ) -> AssistQuizView {
        let chatBotInteractor = makeChatBotInteractor(
            courseID: courseID,
            pageURL: pageURL,
            fileID: fileID
        )
        let viewModel = AssistQuizViewModel(chatBotInteractor: chatBotInteractor, quizzes: quizzes)
        return AssistQuizView(viewModel: viewModel)
    }

    static func makeAIFlashCardView(
        courseID: String? = nil,
        fileID: String? = nil,
        pageURL: String? = nil,
        flashCards: [AssistFlashCardModel]
    ) -> AssistFlashCardView {
        let router = AppEnvironment.shared.router
        let chatBotInteractor = makeChatBotInteractor(
            courseID: courseID,
            pageURL: pageURL,
            fileID: fileID
        )
        let viewModel = AssistFlashCardViewModel(
            flashCards: flashCards,
            router: router,
            chatBotInteractor: chatBotInteractor
        )
        return AssistFlashCardView(viewModel: viewModel)
    }

    struct RoutingParams {
        let courseID: String?
        let fileID: String?
        let pageURL: String?
        let textSelection: String?

        private static let courseIDKey = "courseID"
        private static let fileIDKey = "fileID"
        private static let pageURLKey = "pageURL"
        private static let textSelectionKey = "textSelection"

        init(
            courseID: String? = nil,
            fileID: String? = nil,
            pageURL: String? = nil,
            textSelection: String? = nil
        ) {
            self.courseID = courseID
            self.fileID = fileID
            self.pageURL = pageURL
            self.textSelection = textSelection
        }

        init(from queryItems: [URLQueryItem]) {
            self.courseID = queryItems.first(where: { $0.name == RoutingParams.courseIDKey })?.value
            self.fileID = queryItems.first(where: { $0.name == RoutingParams.fileIDKey })?.value
            self.pageURL = queryItems.first(where: { $0.name == RoutingParams.pageURLKey })?.value
            self.textSelection = queryItems.first(where: { $0.name == RoutingParams.textSelectionKey })?.value
        }

        var queryString: String {
            [
                RoutingParams.courseIDKey: courseID,
                RoutingParams.fileIDKey: fileID,
                RoutingParams.pageURLKey: pageURL,
                RoutingParams.textSelectionKey: textSelection
            ].map { (key, value) in
                guard let value = value else { return nil }
                return "\(key)=\(value)"
            }
            .compactMap { $0 }
            .joined(separator: "&")
        }
    }
}
