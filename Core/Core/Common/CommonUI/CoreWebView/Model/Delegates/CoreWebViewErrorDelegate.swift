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

/**
 This delegate is used to communicate a rendering failure when the underlying web process terminates.
 */
public protocol CoreWebViewErrorDelegate: AnyObject {

    /** This method should return a view to where the error view can be placed blocking it completely. */
    func containerForContentErrorView() -> UIView
    /** If a URL is returned here then the error view will also display a "Open In Browser" button that forwards this URL to the system browser. */
    func urlForExternalBrowser() -> URL?
}
