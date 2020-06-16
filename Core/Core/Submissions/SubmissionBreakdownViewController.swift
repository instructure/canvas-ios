//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import UIKit

class SubmissionBreakdownViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var gradedButton: UIButton!
    @IBOutlet weak var gradedCountLabel: UILabel!
    @IBOutlet weak var gradedLabel: UILabel!
    @IBOutlet weak var gradedProgress: CircleProgressView!
    @IBOutlet weak var gradedView: UIView!

    @IBOutlet weak var ungradedButton: UIButton!
    @IBOutlet weak var ungradedCountLabel: UILabel!
    @IBOutlet weak var ungradedLabel: UILabel!
    @IBOutlet weak var ungradedProgress: CircleProgressView!
    @IBOutlet weak var ungradedView: UIView!

    @IBOutlet weak var unsubmittedButton: UIButton!
    @IBOutlet weak var unsubmittedCountLabel: UILabel!
    @IBOutlet weak var unsubmittedLabel: UILabel!
    @IBOutlet weak var unsubmittedProgress: CircleProgressView!
    @IBOutlet weak var unsubmittedView: UIView!

    @IBOutlet weak var onPaperLabel: UILabel!
    @IBOutlet weak var noSubmissionsLabel: UILabel!

    var assignmentID = ""
    var context = Context.currentUser
    var didAppear = false
    let env = AppEnvironment.shared
    var submissionsPath: String { "\(context.pathComponent)/assignments/\(assignmentID)/submissions" }
    var submissionTypes: [SubmissionType] = []

    lazy var summary = env.subscribe(GetSubmissionSummary(context: context, assignmentID: assignmentID)) { [weak self] in
        self?.update()
    }

    static func create(courseID: String, assignmentID: String, submissionTypes: [SubmissionType]) -> SubmissionBreakdownViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.context = Context(.course, id: courseID)
        controller.submissionTypes = submissionTypes
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = nil

        button.accessibilityLabel = NSLocalizedString("View All Submissions", bundle: .core, comment: "")
        titleLabel.text = NSLocalizedString("Submissions", bundle: .core, comment: "")

        gradedButton.accessibilityLabel = NSLocalizedString("Show graded submissions", bundle: .core, comment: "")
        gradedCountLabel.text = ""
        gradedLabel.text = NSLocalizedString("Graded", bundle: .core, comment: "")
        gradedProgress.progress = 0
        gradedView.isHidden = true

        ungradedButton.accessibilityLabel = NSLocalizedString("Show submissions that need grading", bundle: .core, comment: "")
        ungradedCountLabel.text = ""
        ungradedLabel.text = NSLocalizedString("Needs Grading", bundle: .core, comment: "")
        ungradedProgress.progress = 0
        ungradedView.isHidden = true

        unsubmittedButton.accessibilityLabel = NSLocalizedString("Show submissions not turned in", bundle: .core, comment: "")
        unsubmittedCountLabel.text = ""
        unsubmittedLabel.text = NSLocalizedString("Not Submitted", bundle: .core, comment: "")
        unsubmittedProgress.progress = 0
        unsubmittedView.isHidden = true

        onPaperLabel.isHidden = true
        noSubmissionsLabel.isHidden = true
        noSubmissionsLabel.text = NSLocalizedString("Tap to view submissions list.", bundle: .core, comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        summary.refresh(force: true)
        didAppear = true
        update()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didAppear = false
    }

    // swiftlint:disable large_tuple
    var animateFrom: (Double, Double, Double) = (0, 0, 0)
    var animateTo: (Double, Double, Double) = (0, 0, 0)
    // swiftlint:enable large_tuple
    var animateLink: CADisplayLink?
    var animateStartedAt = Clock.now
    func update() {
        guard let summary = summary.first else { return }
        guard summary.submissionCount > 0 else {
            noSubmissionsLabel.isHidden = false
            gradedView.isHidden = true
            ungradedView.isHidden = true
            unsubmittedView.isHidden = true
            onPaperLabel.isHidden = true
            return
        }

        noSubmissionsLabel.isHidden = true
        gradedView.isHidden = false
        ungradedView.isHidden = submissionTypes.contains(.on_paper)
        unsubmittedView.isHidden = submissionTypes.contains(.on_paper)

        onPaperLabel.isHidden = !submissionTypes.contains(.on_paper)
        onPaperLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("there_are_d_assignees_without_grades", bundle: .core, comment: ""),
            summary.ungraded + summary.unsubmitted
        )

        let animateTo = (Double(summary.graded), Double(summary.ungraded), Double(summary.unsubmitted))
        guard didAppear, self.animateTo != animateTo else { return }
        animateFrom = self.animateTo
        self.animateTo = animateTo
        animateLink?.invalidate()
        animateLink = CADisplayLink(target: self, selector: #selector(stepAnimate))
        animateStartedAt = Clock.now
        animateLink?.add(to: .current, forMode: .default)
        stepAnimate()
    }

    @objc func stepAnimate() {
        let duration: TimeInterval = 0.5
        let animStep = min(1, Clock.now.timeIntervalSince(animateStartedAt) / duration)
        if animStep == 1 {
            animateLink?.invalidate()
            animateLink = nil
        }
        let t = 1 - pow(1 - animStep, 3) // easeOutCubic
        let total = animateTo.0 + animateTo.1 + animateTo.2

        let graded = animateFrom.0 + (t * (animateTo.0 - animateFrom.0))
        gradedCountLabel.text = NumberFormatter.localizedString(from: NSNumber(value: floor(graded)), number: .none)
        gradedProgress.progress = CGFloat(graded / total)

        let ungraded = animateFrom.1 + (t * (animateTo.1 - animateFrom.1))
        ungradedCountLabel.text = NumberFormatter.localizedString(from: NSNumber(value: floor(ungraded)), number: .none)
        ungradedProgress.progress = CGFloat(ungraded / total)

        let unsubmitted = animateFrom.2 + (t * (animateTo.2 - animateFrom.2))
        unsubmittedCountLabel.text = NumberFormatter.localizedString(from: NSNumber(value: floor(unsubmitted)), number: .none)
        unsubmittedProgress.progress = CGFloat(unsubmitted / total)
    }

    @IBAction func routeToAll() {
        env.router.route(to: submissionsPath, from: self)
    }

    @IBAction func routeToGraded() {
        env.router.route(to: "\(submissionsPath)?filterType=graded", from: self)
    }

    @IBAction func routeToUngraded() {
        env.router.route(to: "\(submissionsPath)?filterType=ungraded", from: self)
    }

    @IBAction func routeToUnsubmitted() {
        env.router.route(to: "\(submissionsPath)?filterType=not_submitted", from: self)
    }
}
