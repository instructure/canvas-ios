//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit

enum SubmissionViewState {
    case loading
    case successful
    case failed
}

class SubmissionConfirmationViewController: UIViewController {

    @objc var requiresLockdownBrowserForViewingResults: Bool = false
    @objc var resultsURL: URL?
    @objc var customLoadingText: String?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var resultsButton: UIButton!
    
    fileprivate var successImage: UIImage {
        return UIImage(named: "submitted", in: Bundle(for: SubmissionConfirmationViewController.self), compatibleWith: nil)!
    }
    
    fileprivate var failedImage: UIImage {
        return UIImage(named: "error", in: Bundle(for: SubmissionConfirmationViewController.self), compatibleWith: nil)!
    }
    
    @objc init(resultsURL: URL?, requiresLockdownBrowserForViewingResults: Bool) {
        self.resultsURL = resultsURL
        self.requiresLockdownBrowserForViewingResults = requiresLockdownBrowserForViewingResults
        super.init(nibName: "SubmissionConfirmationViewController", bundle: Bundle(for: SubmissionConfirmationViewController.self))
        let _ = self.view // force the loading of the nib and connection of the outlets
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavigationBar()
    }

    fileprivate func prepareNavigationBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SubmissionConfirmationViewController.doneTapped(_:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func showState(_ state: SubmissionViewState) {
        switch state {
        case .loading:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            statusImageView.isHidden = true
            if customLoadingText != nil {
                infoLabel.text = customLoadingText!
            } else {
                infoLabel.text = NSLocalizedString("Submitting Quiz", tableName: "Localizable", bundle: .core, value: "", comment: "Label for indication of submitting quiz")
            }
            resultsButton.isHidden = true
        case .successful:
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            statusImageView.image = successImage
            statusImageView.isHidden = false
            animateImagePop()
            infoLabel.text = NSLocalizedString("Quiz Submitted", tableName: "Localizable", bundle: .core, value: "", comment: "Label for indication that the quiz submission was successful")
            resultsButton.isHidden = (resultsURL == nil)
            break
        case .failed:
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            statusImageView.image = failedImage
            statusImageView.isHidden = false
            animateImagePop()
            infoLabel.text = NSLocalizedString("QuizSubmission Failure", tableName: "Localizable", bundle: .core, value: "", comment: "Label for indication that the quiz submission failed")
            resultsButton.isHidden = true
            break
        }
    }
    
    fileprivate func animateImagePop() {
        let totalDuration = 0.6
        let keyframeDuration = totalDuration / 3
        statusImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.animateKeyframes(withDuration: totalDuration, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0*keyframeDuration, relativeDuration: keyframeDuration, animations: {
                self.statusImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
            UIView.addKeyframe(withRelativeStartTime: 1*keyframeDuration, relativeDuration: keyframeDuration, animations: {
                self.statusImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
            UIView.addKeyframe(withRelativeStartTime: 2*keyframeDuration, relativeDuration: keyframeDuration, animations: {
                self.statusImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }, completion: nil)
    }
    
    // MARK: Actions
    
    @objc func doneTapped(_ button: UIBarButtonItem?) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil) // go back 2 screens
    }
    
    @IBAction fileprivate func resultsTapped(_ button: UIButton?) {
        if requiresLockdownBrowserForViewingResults {
            let alert = UIAlertController(title: NSLocalizedString("Lockdown Browser Required", tableName: "Localizable", bundle: .core, value: "", comment: "Title for when another tool called Lockdown Browser is required to take a quiz"), message: NSLocalizedString("Lockdown Browser is required for viewing your results. Please open the quiz in Lockdown Browser to continue.", tableName: "Localizable", bundle: .core, value: "", comment: "Detail label for when a tool called Lockdown Browser is required to take the quiz"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "Localizable", bundle: .core, value: "", comment: ""), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if let resultsURL = resultsURL {
            UIApplication.shared.open(resultsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
