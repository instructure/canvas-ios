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

    @Environment(\.appEnvironment) var env
    @Published public private(set) var state: ViewModelState<[LibraryComment]> = .loading
    private var settings: Store<GetUserSettings>
    public var shouldShowCommentLibrary: Bool {
        settings.first?.commentLibrarySuggestionsEnabled ?? false
    }
    public var comment: String = "" {
        didSet {
            filteredComments = comments.filter { comment.isEmpty || $0.text.lowercased().contains(comment.lowercased()) }
        }
    }
    private var filteredComments: [LibraryComment] = [] {
        didSet {
            if filteredComments.isEmpty {
                state = .empty
            } else {
                state = .data(filteredComments)
            }
        }
    }
    private var comments: [LibraryComment] = [] {
        didSet {
            filteredComments = comments.filter { comment.isEmpty || $0.text.lowercased().contains(comment.lowercased()) }
        }
    }

    init() {
        self.settings = AppEnvironment.shared.subscribe(GetUserSettings(userID: "self"))
    }

    public func viewDidAppear() {
        fetchSettings() {
            if self.shouldShowCommentLibrary {
                self.refresh()
            }
        }
    }

    func fetchSettings(_ completion: @escaping () -> Void) {
        self.settings.refresh(force: true) {_ in
            completion()
        }
    }

    func text(with string: String, boldRange: Binding<String>) -> Text {
        if #available(iOS 15, *) {
            return Text(string) {
                if let range = $0.range(of: boldRange.wrappedValue, options: .caseInsensitive) {
                    $0[range].font = .bold17
                }
            }
        }
        return Text(string)
    }
}

extension SubmissionCommentLibraryViewModel: Refreshable {
    public func refresh(completion: @escaping () -> Void) {
        state = .loading
        let userId = env.currentSession?.userID ?? ""
        let requestable = CommentLibraryRequest(userId: userId)
        env.api.makeRequest(requestable, refreshToken: false) { response, _, _  in
            performUIUpdate {
                guard let response = response else { return }
                self.comments = response.comments.map { LibraryComment(id: $0.id, text: $0.comment)}
                completion()
            }
        }
    }
}

class LibraryComment: Identifiable, Hashable {

    let id: ID
    let text: String

    internal init(id: String, text: String) {
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
