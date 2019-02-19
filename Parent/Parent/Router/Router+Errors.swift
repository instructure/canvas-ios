//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation


import Marshal
import CanvasCore

extension Router {
    func defaultErrorHandler() -> ((UIViewController, NSError) -> ()) {
        return { [unowned self] viewController, error in
            let networkError = error.domain == "com.instructure.TooLegit"
            if networkError {
                switch error.code {
                case 403:
                    guard let s = self.session else { self.presentGenericNetworkError(viewController, error: error); return }
                    Student.refreshForAccessRemoved(session: s, from: viewController)
                case 401:
                    guard let s = self.session else { self.presentNotAuthorizedError(viewController, error: error); return }
                    AirwolfAPI.validateSession(s, parentID: s.user.id) { success in
                        if success {
                            self.presentNotAuthorizedError(viewController, error: error)
                        } else {
                            DispatchQueue.main.async {
                                CanvasKeymaster.the().logout()
                            }
                        }
                    }
                case 404:
                    self.presentResourceNotFoundError(viewController, error: error)
                case 500..<600:
                    self.presentServerError(viewController, error: error)
                default:
                    self.presentGenericNetworkError(viewController, error: error)
                }
            }
        }
    }
}

// Handle 401 Errors
extension Router {
    func presentNotAuthorizedError(_ viewController: UIViewController, error: NSError) {
        presentGenericError(viewController,
                            title: NSLocalizedString("Not Authorized", comment: "Not Authorized Error Title"),
                            message: NSLocalizedString("You are unauthorized to access this information.  Check your user permissions and try again.", comment: "Not Authorized Error Message"))
    }
}

// Handle 404 Errors
extension Router {
    func presentResourceNotFoundError(_ viewController: UIViewController, error: NSError) {
        presentGenericError(viewController,
                            title: NSLocalizedString("Not Found", comment: "Not Found Error Title"),
                            message: NSLocalizedString("Resource not found.  Please try again.", comment: "Not Found Error Message"))
    }
}

// Handle 500 Errors
extension Router {
    func presentServerError(_ viewController: UIViewController, error: NSError) {
        presentGenericError(viewController,
                            title: NSLocalizedString("Server Error", comment: "Server Error Title"),
                            message: NSLocalizedString("A server error has occurred.  Please try again.", comment: "Server Error Message"))
    }
}

// Handle Generic Network Errors
extension Router {
    func presentGenericNetworkError(_ viewController: UIViewController, error: NSError) {
        presentGenericError(viewController,
                            title: NSLocalizedString("Network Error", comment: "Generic Network Error Title"),
                            message: NSLocalizedString("An unexpected error occurred.  Please try again.", comment: "Generic Network Error Message"))
    }
}

// Handle Generic Network Errors
extension Router {
    func presentGenericError(_ viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .default, handler: { _ in
        }))

        viewController.present(alert, animated: true, completion: nil)
    }
}

