//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

extension NSError {
    public struct Constants {
        public static let domain = "com.instructure"
        public static let internalError = "Internal Error"
    }

    public static func internalError(code: Int = 0) -> NSError {
        return instructureError(Constants.internalError)
    }

    public static func instructureError(_ errorMsg: String, code: Int = 0) -> NSError {
        return NSError(domain: Constants.domain, code: code, userInfo: [NSLocalizedDescriptionKey: errorMsg])
    }

    public static func errorCodeForHttpResponse(_ response: URLResponse?) -> Int {
        guard let response = response as? HTTPURLResponse else {
            return 0
        }
        let status = response.statusCode
        switch status {
        case 401: return HttpError.unauthorized
        case 403: return HttpError.forbidden
        case 404: return HttpError.notFound
        default: return HttpError.unexpected
        }
    }

    public var shouldRecordInCrashlytics: Bool {
        switch (domain, code) {
        case
            (NSCocoaErrorDomain, 13), // NSCocoaErrorDomain 13 NSUnderlyingException: error during SQL execution : database or disk is full
            (NSURLErrorDomain, NSURLErrorNotConnectedToInternet),
            (NSURLErrorDomain, NSURLErrorTimedOut),
            (NSURLErrorDomain, NSURLErrorNetworkConnectionLost),
            (NSURLErrorDomain, NSURLErrorDataNotAllowed):
            return false
        default:
            return true
        }
    }

    public func showAlert(from: UIViewController?) {
        guard let from = from else { return }
        let dismiss = AlertAction(String(localized: "Dismiss", bundle: .core, comment: "Dismiss button for error messages"), style: .default)

        let report = AlertAction(String(localized: "Report", bundle: .core, comment: "Button to report an error"), style: .default) { _ in
            AppEnvironment.shared.router.show(ErrorReportViewController.create(error: self), from: from, options: .modal(embedInNav: true))
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        switch (domain, code) {
        case (NSCocoaErrorDomain, 13): // NSCocoaErrorDomain 13 NSUnderlyingException: error during SQL execution : database or disk is full
            alert.title = String(localized: "Disk Error", bundle: .core)
            alert.message = String(localized: "Your device is out of storage space. Please free up space and try again.", bundle: .core)
            alert.addAction(dismiss)

        case (NSURLErrorDomain, _):
            alert.title = String(localized: "Network Error", bundle: .core)
            alert.message = localizedDescription
            alert.addAction(report)
            alert.addAction(dismiss)

        case ("com.instructure.canvas", 90211): // push channel error. no idea where 90211 comes from.
            alert.title = String(localized: "Notification Error", bundle: .core)
            alert.message = String(localized: "There was a problem registering your device for push notifications.", bundle: .core)
            alert.addAction(report)
            alert.addAction(dismiss)

        default:
            alert.title = String(localized: "Unknown Error", bundle: .core)
            alert.message = localizedFailureReason.flatMap {
                "\(localizedDescription)\n\n\($0)"
            } ?? localizedDescription
            alert.addAction(report)
            alert.addAction(dismiss)
        }
        AppEnvironment.shared.router.show(alert, from: from, options: .modal())
    }
}
