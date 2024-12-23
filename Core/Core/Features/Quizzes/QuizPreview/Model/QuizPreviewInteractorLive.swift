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

import Combine

public class QuizPreviewInteractorLive: QuizPreviewInteractor {
    public let state = CurrentValueSubject<QuizPreviewInteractorState, Never>(.loading)

    private let quizStore: Store<GetQuiz>
    private var subscriptions = Set<AnyCancellable>()

    public init(courseID: String, quizID: String, env: AppEnvironment) {
        let useCase = GetQuiz(courseID: courseID, quizID: quizID)
        quizStore = env.subscribe(useCase)

        Publishers
            .CombineLatest(quizStore.statePublisher,
                           quizStore.allObjects)
            .map { (state, quizzes) in
                switch state {
                case .loading:
                    return .loading
                case .error, .empty:
                    return .error
                case .data:
                    if let url = quizzes.first?.htmlURL {
                        // We don't need to authenticate this url since we already
                        // have an active session cookie in the webview
                        return .data(launchURL: url.previewURL)
                    } else {
                        return .error
                    }
                }
            }
            .subscribe(state)
            .store(in: &subscriptions)

        quizStore.refresh()
    }
}

private extension URL {
    var previewURL: URL {
        var result = self
        result = result.appendingPathComponent("take")
        result = result.appendingQueryItems(
            URLQueryItem(name: "preview", value: "1"),
            URLQueryItem(name: "persist_headless", value: "1"),
            URLQueryItem(name: "force_user", value: "1")
        )
        return result
    }
}
