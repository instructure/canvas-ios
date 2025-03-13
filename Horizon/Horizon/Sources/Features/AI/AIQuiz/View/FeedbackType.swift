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

import SwiftUI

<<<<<<<< HEAD:Horizon/Horizon/Sources/Features/AI/AIQuiz/View/FeedbackType.swift
enum FeedbackType: CaseIterable {
    case like
    case dislike

    var selectedImage: String {
        switch self {
        case .like:
            "hand.thumbsup.fill"
        case .dislike:
            "hand.thumbsdown.fill"
        }
    }

    var unselectedImage: String {
        switch self {
        case .like:
            "hand.thumbsup"
        case .dislike:
            "hand.thumbsdown"
        }
    }
========
public protocol SearchViewsProvider {
    associatedtype Filter: SearchPreference
    associatedtype FilterEditor: View
    associatedtype Support: SearchSupportAction
    associatedtype SearchContent: View

    var supportButtonModel: SearchSupportButtonModel<Support>? { get }

    func contentView(_ filter: Binding<Filter?>) -> SearchContent
    func filterEditorView(_ filter: Binding<Filter?>) -> FilterEditor
}

public protocol SearchPreference {
    var isActive: Bool { get }
>>>>>>>> origin/master:Core/Core/Features/Search/View/SearchViewsProvider.swift
}
