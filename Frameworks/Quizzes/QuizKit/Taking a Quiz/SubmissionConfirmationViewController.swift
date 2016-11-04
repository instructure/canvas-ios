
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit

enum SubmissionViewState {
    case Loading
    case Successful
    case Failed
}

class SubmissionConfirmationViewController: UIViewController {
    
    var resultsURL: NSURL?
    var customLoadingText: String?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var resultsButton: UIButton!
    
    private var successImage: UIImage {
        return UIImage(named: "submitted", inBundle: NSBundle(forClass: SubmissionConfirmationViewController.self), compatibleWithTraitCollection: nil)!
    }
    
    private var failedImage: UIImage {
        return UIImage(named: "error", inBundle: NSBundle(forClass: SubmissionConfirmationViewController.self), compatibleWithTraitCollection: nil)!
    }
    
    init(resultsURL: NSURL?) {
        self.resultsURL = resultsURL
        super.init(nibName: "SubmissionConfirmationViewController", bundle: NSBundle(forClass: SubmissionConfirmationViewController.self))
        let _ = self.view // force the loading of the nib and connection of the outlets
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavigationBar()
    }

    private func prepareNavigationBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(SubmissionConfirmationViewController.doneTapped(_:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func showState(state: SubmissionViewState) {
        switch state {
        case .Loading:
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            statusImageView.hidden = true
            if customLoadingText != nil {
                infoLabel.text = customLoadingText!
            } else {
                infoLabel.text = NSLocalizedString("Submitting Quiz", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Label for indication of submitting quiz")
            }
            resultsButton.hidden = true
        case .Successful:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            statusImageView.image = successImage
            statusImageView.hidden = false
            animateImagePop()
            infoLabel.text = NSLocalizedString("Quiz Submitted", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Label for indication that the quiz submission was successful")
            resultsButton.hidden = (resultsURL == nil)
            break
        case .Failed:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            statusImageView.image = failedImage
            statusImageView.hidden = false
            animateImagePop()
            infoLabel.text = NSLocalizedString("Submission Failure", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Label for indication that the quiz submission failed")
            resultsButton.hidden = true
            break
        }
    }
    
    private func animateImagePop() {
        let totalDuration = 0.6
        let keyframeDuration = totalDuration / 3
        statusImageView.transform = CGAffineTransformMakeScale(1, 1)
        UIView.animateKeyframesWithDuration(totalDuration, delay: 0, options: [], animations: {
            UIView.addKeyframeWithRelativeStartTime(0*keyframeDuration, relativeDuration: keyframeDuration, animations: {
                self.statusImageView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            })
            UIView.addKeyframeWithRelativeStartTime(1*keyframeDuration, relativeDuration: keyframeDuration, animations: {
                self.statusImageView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            })
            UIView.addKeyframeWithRelativeStartTime(2*keyframeDuration, relativeDuration: keyframeDuration, animations: {
                self.statusImageView.transform = CGAffineTransformMakeScale(1, 1)
            })
        }, completion: nil)
    }
    
    // MARK: Actions
    
    func doneTapped(button: UIBarButtonItem?) {
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil) // go back 2 screens
    }
    
    @IBAction private func resultsTapped(button: UIButton?) {
        UIApplication.sharedApplication().openURL(resultsURL!)
    }
}
