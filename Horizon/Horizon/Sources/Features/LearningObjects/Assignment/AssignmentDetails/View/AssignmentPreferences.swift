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

<<<<<<<< HEAD:Horizon/Horizon/Sources/Features/LearningObjects/Assignment/AssignmentDetails/View/AssignmentPreferences.swift
import SwiftUICore

enum AssignmentPreferenceKeyType: Equatable {
    case confirmation(viewModel: SubmissionAlertViewModel)
    case toastViewModel(viewModel: ToastViewModel)
}

struct HeaderVisibilityKey: PreferenceKey {
    static var defaultValue: Bool = true

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct AssignmentPreferenceKey: PreferenceKey {
    static var defaultValue: AssignmentPreferenceKeyType?

    static func reduce(value: inout AssignmentPreferenceKeyType?, nextValue: () -> AssignmentPreferenceKeyType?) {
        value = nextValue()
========
import WebKit

public protocol EmbeddedWebPageViewModel {
    var urlPathComponent: String { get }
    var queryItems: [URLQueryItem] { get }
    var navigationBarTitle: String { get }

    func leadingNavigationButton(host: UIViewController) -> InstUI.NavigationBarButton?
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
}

public extension EmbeddedWebPageViewModel {

    func leadingNavigationButton(host: UIViewController) -> InstUI.NavigationBarButton? {
        nil
>>>>>>>> origin/master:Core/Core/Common/CommonUI/EmbeddedWebPage/ViewModel/EmbeddedWebPageViewModel.swift
    }

    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {}
}
