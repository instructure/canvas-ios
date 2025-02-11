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
import Combine
import SwiftUI

class SubmissionCommentLibraryViewModel: ObservableObject {

    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }

    @Published public private(set) var state: ViewModelState<[LibraryComment]> = .loading
    @Published public var endCursor: String?

    public var shouldShow: Bool {
        settings.first?.commentLibrarySuggestionsEnabled ?? false
    }

    public var comment: String {
        get { commentSubject.value }
        set { commentSubject.send(newValue) }
    }

    private var settings = AppEnvironment.shared.subscribe(GetUserSettings(userID: "self"))
    private var commentSubject = CurrentValueSubject<String, Never>("")

    private let env = AppEnvironment.shared
    private var subscriptions = Set<AnyCancellable>()
    private var comments: [LibraryComment] = []

    init() {
        commentSubject
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .mapToVoid()
            .flatMap({
                return Future { [weak self] promise in
                    self?.refresh(completion: { promise(.success) })
                }
            })
            .sink(receiveValue: {})
            .store(in: &subscriptions)
    }

    func viewDidAppear(completion: (() -> Void)? = nil) {
        fetchSettings {
            if self.shouldShow {
                self.refresh(completion: { completion?() })
            }
        }
    }

    private func fetchSettings(_ completion: @escaping () -> Void) {
        settings.refresh(force: true) { _ in
            completion()
        }
    }

    func attributedText(with string: String, rangeString: Binding<String>, attributes: AttributeContainer) -> Text {
        Text(string) {
            if let range = $0.range(of: rangeString.wrappedValue, options: .caseInsensitive) {
                $0[range].setAttributes(attributes)
            }
        }
    }

    func loadNextPage(completion: @escaping () -> Void) {
        Task { @MainActor in
            await self.fetchNextPage()
            completion()
        }
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

    @MainActor
    public func refresh() async {
        self.state = .loading

        let userId = env.currentSession?.userID ?? ""
        let requestable = APICommentLibraryRequest(query: comment, userId: userId)

        do {
            let response = try await env.api.makeRequest(requestable)
            let comments = response.comments.map { LibraryComment(id: $0.id, text: $0.comment)}
            self.comments = comments
            self.endCursor = response.pageInfo?.nextCursor
            self.state = .data(comments)
        } catch { }
    }

    @MainActor
    public func fetchNextPage() async {
        guard let endCursor else { return }

        let userId = env.currentSession?.userID ?? ""
        let requestable = APICommentLibraryRequest(
            query: comment,
            userId: userId,
            cursor: endCursor
        )

        if let response = try? await env.api.makeRequest(requestable) {
            let newComments = response.comments.map { LibraryComment(id: $0.id, text: $0.comment)}
            let allComments = self.comments + newComments
            self.comments = allComments

            self.state = .data(allComments)
            self.endCursor = response.pageInfo?.nextCursor
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
