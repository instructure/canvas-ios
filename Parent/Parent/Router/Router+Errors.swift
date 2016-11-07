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

import Airwolf
import Marshal
import SoLazy

extension Router {
    func defaultErrorHandler() -> ((UIViewController, NSError) -> ()) {
        return { [unowned self] viewController, error in
            let networkError = error.domain == "com.instructure.TooLegit"
            if networkError {
                switch error.code {
                case 401:
                    self.presentNotAuthorizedError(viewController, error: error)
                case 404:
                    self.presentResourceNotFoundError(viewController, error: error)
                case 418:
                    self.presentUnauthorizedUserError(viewController, error: error)
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
    func presentNotAuthorizedError(viewController: UIViewController, error: NSError) {
        presentGenericError(viewController,
                            title: NSLocalizedString("Not Authorized", comment: "Not Authorized Error Title"),
                            message: NSLocalizedString("You are unauthorized to access this information.  Check your user permissions and try again.", comment: "Not Authorized Error Message"))
    }
}

// Handle 404 Errors
extension Router {
    func presentResourceNotFoundError(viewController: UIViewController, error: NSError) {
        presentGenericError(viewController,
                            title: NSLocalizedString("Not Found", comment: "Not Found Error Title"),
                            message: NSLocalizedString("Resource not found.  Please try again.", comment: "Not Found Error Message"))
    }
}


// Handle 418 Errors
extension Router {
    func presentUnauthorizedUserError(viewController: UIViewController, error: NSError) {
        guard let data = error.data,
            dictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? Dictionary<String, AnyObject>,
            name = dictionary["student_name"] as? String else {
                ❨╯°□°❩╯⌢"Can't remove student without user info"
        }

        let message = String.localizedStringWithFormat("You are unauthorized to access information for %@.", name)
        let style = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? UIAlertControllerStyle.Alert : UIAlertControllerStyle.ActionSheet
        let alert = UIAlertController(title: NSLocalizedString("Access Denied", comment: "Unauthorized Student Error Title"), message: message, preferredStyle: style)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove Student", comment: "delete student from login"), style: .Destructive, handler: { _ in
            self.removeStudentPressed(viewController, dictionary: dictionary)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Repair Access", comment: "re-authenticate user when token fails"), style: .Default, handler: { _ in
            self.route(viewController, toURL: self.addStudentRoute())
        }))

        viewController.presentViewController(alert, animated: true, completion: nil)
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    func removeStudentPressed(viewController: UIViewController, dictionary: Dictionary<String, AnyObject>) {
        guard let name = dictionary["student_name"] as? String,
            studentID = dictionary["student_id"] as? String else {
            ❨╯°□°❩╯⌢"Can't remove student without name and ID"
        }

        let message = String.localizedStringWithFormat("Are you sure you want to remove %@.", name)
        let style = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? UIAlertControllerStyle.Alert : UIAlertControllerStyle.ActionSheet
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: style)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .Cancel) { _ in }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: NSLocalizedString("Remove", comment: "Remove button title"), style: .Destructive) { [unowned self] _ in
            self.removeStudent(studentID)
        }
        alertController.addAction(destroyAction)

        viewController.presentViewController(alertController, animated: true) { }
    }

    func removeStudent(studentID: String) {
        guard let session = session else { return }
        let studentObserver = try! Student.observer(session, studentID: studentID)

        // TODO: Show Animation - This is a nice to have and should be added in 1.1`
        guard let student = studentObserver.object else { return }
        student.remove(session) { result in
            dispatch_async(dispatch_get_main_queue()) {
                // TODO: Hide Animation
            }
        }
    }
}

// Handle 500 Errors
extension Router {
    func presentServerError(viewController: UIViewController, error: NSError) {
        presentGenericError(viewController,
                            title: NSLocalizedString("Server Error", comment: "Server Error Title"),
                            message: NSLocalizedString("A server error has occurred.  Please try again.", comment: "Server Error Message"))
    }
}

// Handle Generic Network Errors
extension Router {
    func presentGenericNetworkError(viewController: UIViewController, error: NSError) {
        presentGenericError(viewController,
                            title: NSLocalizedString("Network Error", comment: "Generic Network Error Title"),
                            message: NSLocalizedString("An unexpected error occurred.  Please try again.", comment: "Generic Network Error Message"))
    }
}

// Handle Generic Network Errors
extension Router {
    func presentGenericError(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .Default, handler: { _ in
        }))

        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}

