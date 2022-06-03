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
import FirebaseAnalytics
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

        if let session = LoginSession.mostRecent {
            AppEnvironment.shared.userDidLogin(session: session)
        }

        // extensionContext is nil in init so we have to initialize here
        attachmentCopyService = AttachmentCopyService(extensionContext: extensionContext)
        attachmentSubmissionService = AttachmentSubmissionService()
        viewModel = SubmitAssignmentExtensionViewModel(
            attachmentCopyService: attachmentCopyService,
            submissionService: attachmentSubmissionService,
            shareCompleted: { [weak self] in
                performUIUpdate {
                    self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            }
        )

        embed(CoreHostingController(SubmitAssignmentExtensionView(viewModel: viewModel)), in: view)
    }

    private func setupFirebaseServices() {
        guard FirebaseOptions.defaultOptions()?.apiKey != nil else { return }
        FirebaseApp.configure()
        Core.Analytics.shared.handler = self
    }
}

extension SubmitAssignmentViewController: Core.AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent("sharex_\(name)", parameters: parameters)
    }
}
