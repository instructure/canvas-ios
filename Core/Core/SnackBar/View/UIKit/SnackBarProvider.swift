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

public protocol SnackBarProvider {
    var snackBarViewModel: SnackBarViewModel { get }
}

public extension UIViewController {

    func findSnackBarViewModel() -> SnackBarViewModel? {
        let possibleProviders = [
            self,
            tabBarController,
            presentingViewController,
            presentingViewController?.tabBarController
        ]

        let provider = possibleProviders
            .compactMap { $0 as? SnackBarProvider }
            .first
        return provider?.snackBarViewModel
    }
}

public extension SnackBarProvider where Self: UITabBarController {

    func addSnackBar() {
        let snackBarController = SnackBarViewController(viewModel: snackBarViewModel)
        let snackView = snackBarController.view!
        view.addSubview(snackView)
        snackView.pin(inside: view, bottom: nil)

        if isRegularBottomTabBarEnsured {
            // constrain to `tabBar` only if it is ensured that it is part of the view hierarchy
            snackView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 0).isActive = true
        } else {
            // as a fallback, constrain to `view` which will result in the snackbar overlapping some of the tabbar
            snackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
    }

    private var isRegularBottomTabBarEnsured: Bool {
        view.subviews.contains(tabBar)
    }
}
