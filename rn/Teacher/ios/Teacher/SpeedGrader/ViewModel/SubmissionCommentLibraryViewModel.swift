//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import SwiftUI

class SubmissionCommentLibraryViewModel: ObservableObject {

    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }

    @Published public private(set) var state: ViewModelState<[LibraryComment]> = .loading
    private var settings = AppEnvironment.shared.subscribe(GetUserSettings(userID: "self"))
    public var shouldShow: Bool {
        settings.first?.commentLibrarySuggestionsEnabled ?? false
    }
    public var comment: String = "" {
        didSet {
            updateFilteredComments()
        }
    }
    private let env = AppEnvironment.shared
    private var filteredComments: [LibraryComment] = [] {
        didSet {
            withAnimation {
                if filteredComments.isEmpty {
                    state = .empty
                } else {
                    state = .data(filteredComments)
                }
            }
        }
    }
    private var comments: [LibraryComment] = [] {
        didSet {
            updateFilteredComments()
        }
    }

    func viewDidAppear() {
        fetchSettings {
            if self.shouldShow {
                Task {
                    await self.refresh()
                }
            }
        }
    }

    func attributedText(with string: String, rangeString: Binding<String>, attributes: AttributeContainer) -> Text {
        Text(string) {
            if let range = $0.range(of: rangeString.wrappedValue, options: .caseInsensitive) {
                $0[range].setAttributes(attributes)
            }
        }
    }

    private func fetchSettings(_ completion: @escaping () -> Void) {
        settings.refresh(force: true) { _ in
            completion()
        }
    }

    private func updateFilteredComments() {
        filteredComments = comments.filter { comment.isEmpty || $0.text.lowercased().contains(comment.lowercased()) }
    }
}

extension SubmissionCommentLibraryViewModel: Refreshable {

    @available(*, renamed: "refresh()")
    public func refresh(completion: @escaping () -> Void) {
        Task {
            await refresh()
            completion()
        }
    }

    public func refresh() async {
        state = .loading
        let userId = env.currentSession?.userID ?? ""
        let requestable = APICommentLibraryRequest(userId: userId)
        return await withCheckedContinuation { continuation in
            env.api.makeRequest(requestable) { response, _, _  in
                performUIUpdate {
                    guard let response1 = response else { return }
                    self.comments = response1.comments.map { LibraryComment(id: $0.id, text: $0.comment)}
                    continuation.resume()
                }
            }
        }
    }
}

class LibraryComment: Identifiable, Hashable {

    let id: ID
    let text: String

    init(id: String, text: String) {
        self.id = ID(id)
        self.text = text
    }

    static func == (lhs: LibraryComment, rhs: LibraryComment) -> Bool {
        lhs.id == rhs.id && lhs.text == rhs.text
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(text)
    }
}
