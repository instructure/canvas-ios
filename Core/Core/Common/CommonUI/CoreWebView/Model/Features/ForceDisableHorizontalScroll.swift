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

private class ForceDisableHorizontalScroll: CoreWebViewFeature {
    private let scrollDelegate = DisableHorizontalScrollDelegate()

    override func apply(on webView: CoreWebView) {
        webView.scrollView.delegate = scrollDelegate
    }
}

public extension CoreWebViewFeature {

    /**
     This feature disables horizontal scrolling and bouncing of the webview by overriding any `contentOffset.x changes`.

     **Warning!** This feature uses `webView.scrollView.delegate` and can interfere with other delegate usages.
     */
    static var forceDisableHorizontalScroll: CoreWebViewFeature {
        ForceDisableHorizontalScroll()
    }
}

private class DisableHorizontalScrollDelegate: NSObject, UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
    }
}
