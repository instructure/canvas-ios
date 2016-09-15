//
//  SubmissionConfirmationViewController.swift
//  Quizzes
//
//  Created by Ben Kraus on 3/26/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneTapped:"))
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
                infoLabel.text = NSLocalizedString("Submitting Quiz", comment: "Label for indication of submitting quiz")
            }
            resultsButton.hidden = true
        case .Successful:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            statusImageView.image = successImage
            statusImageView.hidden = false
            animateImagePop()
            infoLabel.text = NSLocalizedString("Quiz Submitted", comment: "Label for indication that the quiz submission was successful")
            resultsButton.hidden = (resultsURL == nil)
            break
        case .Failed:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            statusImageView.image = failedImage
            statusImageView.hidden = false
            animateImagePop()
            infoLabel.text = NSLocalizedString("Submission Failure", comment: "Label for indication that the quiz submission failed")
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
