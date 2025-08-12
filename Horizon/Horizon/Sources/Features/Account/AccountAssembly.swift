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

import Core
import UIKit

<<<<<<<< HEAD:Horizon/Horizon/Sources/Features/Notebook/Common/View/HighlightWebView/EnableZoom.swift
private class EnableZoom: CoreWebViewFeature {
    private let script: String =
    """
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
        document.getElementsByTagName('head')[0].appendChild(meta);
    """

    override func apply(on webView: CoreWebView) {
        webView.addScript(script)
========
final class AccountAssembly {
    static func makeView() -> AccountView {
        AccountView(
            viewModel: AccountViewModel(
                getUserInteractor: GetUserInteractorLive()
            )
        )
>>>>>>>> master:Horizon/Horizon/Sources/Features/Account/AccountAssembly.swift
    }

<<<<<<<< HEAD:Horizon/Horizon/Sources/Features/Notebook/Common/View/HighlightWebView/EnableZoom.swift
extension CoreWebViewFeature {
    static var enableZoom: CoreWebViewFeature {
        EnableZoom()
========
    #if DEBUG
    static func makePreview() -> AccountView {
        let getUserInteractorPreview = GetUserInteractorPreview()
        let viewModel = AccountViewModel(
            getUserInteractor: getUserInteractorPreview
        )
        return AccountView(viewModel: viewModel)
>>>>>>>> master:Horizon/Horizon/Sources/Features/Account/AccountAssembly.swift
    }
    #endif
}
