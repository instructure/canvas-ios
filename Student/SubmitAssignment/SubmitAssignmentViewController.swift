//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import Firebase
import UIKit
import Social

@objc(SubmitAssignmentViewController)
class SubmitAssignmentViewController: UIViewController {

    private var attachmentCopyService: AttachmentCopyService!
    private var attachmentSubmissionService: AttachmentSubmissionService!
    private var viewModel: SubmitAssignmentExtensionViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFirebaseServices()
        isModalInPresentation = true

        let lastApplicationSession = LoginSession.mostRecent
        let currentSession = AppEnvironment.shared.currentSession

        /**
         If we already logged in the user during a previous share but our process didn't terminate we skip logging in the user again,
         otherwise the CoreData stack will be re-initialized resulting in strange errors.
        */
        if currentSession != lastApplicationSession {
            if let lastApplicationSession {
                AppEnvironment.shared.userDidLogin(session: lastApplicationSession)
            } else if let currentSession {
                AppEnvironment.shared.userDidLogout(session: currentSession)
            }
        }

        let shareCompleted = { [weak self] in
           performUIUpdate {
               self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
           }
        }

        // extensionContext is nil in init so we have to initialize here
        attachmentCopyService = AttachmentCopyService(extensionContext: extensionContext)

        /// The share extension process doesn't terminate in case we have a background upload and the user starts another one.
        /// The system just creates a new instance of this viewcontroller. We create a new assembly _after_ logging in
        /// to handle the case when the current user is changed in the app.
        let submissionAssembly: FileSubmissionAssembly = .makeShareExtensionAssembly()
        attachmentSubmissionService = AttachmentSubmissionService(submissionAssembly: submissionAssembly)

        viewModel = SubmitAssignmentExtensionViewModel(
            attachmentCopyService: attachmentCopyService,
            submissionService: attachmentSubmissionService,
            shareCompleted: shareCompleted
        )
        embed(CoreHostingController(SubmitAssignmentExtensionView(viewModel: viewModel)), in: view)
    }

    private func setupFirebaseServices() {
        guard FirebaseOptions.defaultOptions()?.apiKey != nil else { return }
        FirebaseApp.configure()
        Core.Analytics.shared.handler = self
        RemoteLogger.shared.handler = self
    }
}

extension SubmitAssignmentViewController: Core.AnalyticsHandler {

    func handleEvent(_ name: String, parameters: [String: Any]?) {
        // Google Analytics needs to be disabled for now
//        Analytics.logEvent("sharex_\(name)", parameters: parameters)
    }
}

extension SubmitAssignmentViewController: RemoteLogHandler {

    func handleBreadcrumb(_ name: String) {
        Firebase.Crashlytics.crashlytics().log(name)
    }

    func handleError(_ name: String, reason: String) {
        let model = ExceptionModel(name: name, reason: reason)
        Firebase.Crashlytics.crashlytics().record(exceptionModel: model)
    }
}
