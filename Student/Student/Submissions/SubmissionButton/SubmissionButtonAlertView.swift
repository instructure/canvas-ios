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

import Foundation
import MobileCoreServices
import UIKit
import Core

enum SubmissionButtonAlertView {
    static func chooseTypeAlert(_ presenter: SubmissionButtonPresenter, assignment: Assignment, arc: Bool, button: UIView) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for type in assignment.submissionTypes {
            let action = UIAlertAction(title: type.localizedString, style: .default) { [weak presenter] _ in
                presenter?.submitType(type, for: assignment, button: button)
            }
            alert.addAction(action)
        }
        if arc {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Studio", bundle: .student, comment: ""), style: .default) { [weak presenter] _ in
                presenter?.submitArc(assignment: assignment)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .student, comment: ""), style: .cancel))
        // set ipad properties to display modal
        alert.popoverPresentationController?.sourceView = button
        alert.popoverPresentationController?.sourceRect =  CGRect(origin: button.center, size: .zero)
        alert.popoverPresentationController?.permittedArrowDirections = []
        return alert
    }

    static func chooseMediaTypeAlert(_ presenter: SubmissionButtonPresenter, button: UIView, assignment: Assignment) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Record Audio", bundle: .student, comment: ""), style: .default) { [weak presenter] _ in
            AudioRecorderViewController.requestPermission { allowed in
                if allowed {
                    let controller = AudioRecorderViewController.create()
                    controller.delegate = presenter
                    controller.view.backgroundColor = UIColor.named(.backgroundLightest)
                    controller.modalPresentationStyle = .formSheet
                    presenter?.view?.present(controller, animated: true, completion: nil)
                } else {
                    presenter?.view?.showPermissionError(.microphone)
                }
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Record Video", bundle: .student, comment: ""), style: .default) { [weak presenter] _ in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            let cameraController = UIImagePickerController()
            cameraController.delegate = presenter
            cameraController.sourceType = .camera
            cameraController.mediaTypes = [kUTTypeMovie as String]
            cameraController.cameraCaptureMode = .video
            presenter?.view?.present(cameraController, animated: true, completion: nil)
        })

        alert.addAction(UIAlertAction(title: SubmissionType.online_upload.localizedString, style: .default) { [weak presenter] _ in
            presenter?.submitType(SubmissionType.online_upload, for: assignment, button: button)
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .student, comment: ""), style: .cancel))
        alert.popoverPresentationController?.sourceView = button
        alert.popoverPresentationController?.sourceRect = CGRect(origin: button.center, size: .zero)
        alert.popoverPresentationController?.permittedArrowDirections = []
        return alert
    }

    static func uploadingAlert(_ mediaUploader: UploadMedia) -> UIAlertController {
        let uploading = UIAlertController(title: NSLocalizedString("Uploading", bundle: .student, comment: ""), message: nil, preferredStyle: .alert)
        uploading.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .student, comment: ""), style: .destructive) { _ in
            mediaUploader.cancel()
        })
        return uploading
    }
}
