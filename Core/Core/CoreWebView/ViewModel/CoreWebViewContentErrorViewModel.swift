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

import Foundation

class CoreWebViewContentErrorViewModel: ObservableObject {
    public let subtitle: String
    public let shouldDisplayOpenInBrowserButton: Bool
    private let urlToOpenInBrowser: URLComponents?

    public init(urlToOpenInBrowser: URL?) {
        let url = urlToOpenInBrowser.flatMap { URLComponents.parse($0) }
        let displayBrowserButton = (url != nil)
        let subtitle = {
            var result = String(localized: "Something went wrong beyond our control.", bundle: .core)

            if displayBrowserButton {
                result.append("\n")
                result.append(String(localized: "You can try to open the page in a browser.", bundle: .core))
            }

            return result
        }()

        self.urlToOpenInBrowser = url
        self.shouldDisplayOpenInBrowserButton = displayBrowserButton
        self.subtitle = subtitle
    }

    func openInBrowserButtonTapped() {
        guard let urlToOpenInBrowser else { return }
        Router.open(url: urlToOpenInBrowser)
    }
}
