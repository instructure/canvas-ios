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

/**
 When a split view controller is in split mode it's a common behavior that when a view controller is pushed
 to the master area another view controller also shows up in the split view's detail area.
 View controllers implementing this protocol can provide a default view for such situations.
 */
public protocol DefaultViewProvider: UIViewController {
    var defaultViewRoute: String? { get set }
}

extension UIViewController {

    /**
     This method checks if the view controller is a `DefaultViewProvider` with an existing default view.
     If yes and it's in a split view controller in split mode then shows its default view in the split view controller's detail area.
     */
    public func showDefaultDetailView() {
        guard !isInSplitViewDetail,
              let defaultViewProvider = self as? DefaultViewProvider,
              let defaultRoute = defaultViewProvider.defaultViewRoute,
              let splitViewController = splitViewController,
              !splitViewController.isCollapsed
        else {
            return
        }

        AppEnvironment.shared.router.route(to: defaultRoute, from: self, options: .detail)
    }
}
