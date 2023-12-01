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

import UIKit
import QuartzCore
import Core

class Drawer: UIView {
    enum Tab: Int {
        case comments
        case files
        case rubric
    }

    @IBOutlet weak var drawer: UIView?
    @IBOutlet weak var drawerControls: UIView?
    @IBOutlet weak var gripper: UIView?
    @IBOutlet weak var tabs: UISegmentedControl?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint?

    var height: CGFloat = 0
    // this number doesnt seem to be accurate all the time, especially on iphones with a notch
    // Thus this number is more of a starting place. There is a constraint on the drawer to prevent
    // it from going too high
    lazy var maxDrawerHeight: CGFloat = {
        guard let contentViewTopOffset = contentView?.frame.minY, let superViewHeight = superview?.frame.height else {
            return 0
        }
        return superViewHeight - contentViewTopOffset
    }()
    lazy var midDrawerHeight: CGFloat = {
        return maxDrawerHeight / 2
    }()

    var fileCount: Int = 0 {
        didSet {
            let title = String.localizedStringWithFormat(NSLocalizedString("Files (%d)", bundle: .student, comment: ""), fileCount)
            tabs?.setTitle(title, forSegmentAt: Tab.files.rawValue)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.clear
        drawer?.backgroundColor = UIColor.clear
        drawerControls?.backgroundColor = .backgroundLightest
        contentView?.backgroundColor = .backgroundLightest
        gripper?.backgroundColor = .backgroundMedium

        gripper?.layer.cornerRadius = 2
        updateGripperLabel(height: height)
        tabs?.setTitle(NSLocalizedString("Comments", bundle: .student, comment: ""), forSegmentAt: Tab.comments.rawValue)
        tabs?.setTitle(NSLocalizedString("Files", bundle: .student, comment: ""), forSegmentAt: Tab.files.rawValue)
        tabs?.setTitle(NSLocalizedString("Rubric", bundle: .student, comment: ""), forSegmentAt: Tab.rubric.rawValue)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async { [weak self] in
            self?.drawerControls?.roundCorners(corners: [.topLeft, .topRight], radius: 10)
            self?.tabs?.addUnderlineForSelectedSegment()
        }
        addDropShadow()
    }

    func addDropShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -9)
        layer.shadowRadius = 5
        layer.masksToBounds = false
    }

    func updateGripperLabel(height: CGFloat) {
        if height == 0 {
            gripper?.accessibilityLabel = NSLocalizedString("Drawer closed", bundle: .student, comment: "")
        } else if height == midDrawerHeight {
            gripper?.accessibilityLabel = NSLocalizedString("Drawer partially opened", bundle: .student, comment: "")
        } else if height == maxDrawerHeight {
            gripper?.accessibilityLabel = NSLocalizedString("Drawer fully open", bundle: .student, comment: "")
        }
    }

    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        tabs?.changeUnderlinePosition()
    }
}

// DRAWER MOVEMENT

extension Drawer {
    @IBAction func gripperPressed(_ sender: UIButton) {
        if tabs?.selectedSegmentIndex == UISegmentedControl.noSegment {
            tabs?.selectedSegmentIndex = 0
        }
        if height < midDrawerHeight {
            moveTo(height: midDrawerHeight, velocity: 100)
        } else if height == midDrawerHeight {
            moveTo(height: maxDrawerHeight, velocity: 100)
        } else if height > midDrawerHeight {
            moveTo(height: 0, velocity: 100)
        }
    }

    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let currentHeight = contentViewHeight?.constant else {
            return
        }
        if tabs?.selectedSegmentIndex == UISegmentedControl.noSegment {
            tabs?.selectedSegmentIndex = 0
        }
        if gestureRecognizer.state == .ended {
            let velocity = gestureRecognizer.velocity(in: self).y
            let height = determineDrawerSnap(currentHeight: currentHeight, velocity: velocity)
            moveTo(height: height, velocity: velocity)
        } else {
            let newHeight = min(maxDrawerHeight, height - gestureRecognizer.translation(in: self).y)
            contentViewHeight?.constant = newHeight
        }
    }

    func determineDrawerSnap(currentHeight: CGFloat, velocity: CGFloat) -> CGFloat {
        if currentHeight < midDrawerHeight && velocity < 0 {
            return midDrawerHeight
        } else if currentHeight < midDrawerHeight && velocity > 0 {
            return 0
        } else if currentHeight > midDrawerHeight && velocity < 0 {
            return maxDrawerHeight
        } else if currentHeight > midDrawerHeight && velocity > 0 {
            return midDrawerHeight
        }

        return 0
    }

    func moveTo(height: CGFloat, velocity: CGFloat) {
        guard let currentHeight = contentViewHeight?.constant else {
            return
        }
        let distance = height - currentHeight
        // moving too fast made the spring effect weird
        // moving too slow made it too long before it snapped
        let duration = max(0.3, min(0.7, abs(Double(distance / velocity))))

        updateGripperLabel(height: height)

        self.superview?.layoutIfNeeded()
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: velocity / distance, options: [], animations: { [weak self] in
            self?.contentViewHeight?.constant = height
            self?.height = height
            self?.superview?.layoutIfNeeded()
        }, completion: nil)
    }

    func setMiddle() {
        layoutIfNeeded()
        tabs?.selectedSegmentIndex = 0
        tabs?.changeUnderlinePosition()
        updateGripperLabel(height: midDrawerHeight)
        contentViewHeight?.constant = midDrawerHeight
        self.height = midDrawerHeight
    }
}

extension UISegmentedControl {

    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func removeBorders() {
        setBackgroundImage(
            imageWithColor(color: UIColor.clear),
            for: .normal,
            barMetrics: .default
        )
        setBackgroundImage(
            imageWithColor(color: UIColor.clear),
            for: .selected,
            barMetrics: .default
        )
        setDividerImage(
            imageWithColor(color: UIColor.clear),
            forLeftSegmentState: .normal,
            rightSegmentState: .normal,
            barMetrics: .default
        )
    }

    func setFontStyle() {
        setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular14)],
            for: .normal
        )
        setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular14)],
            for: .selected
        )
        setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.textDark],
            for: .normal
        )
        setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.textDark],
            for: .selected
        )
    }

    func addUnderlineForSelectedSegment() {
        if let view = viewWithTag(1) {
            view.removeFromSuperview()
        }
        removeBorders()
        setFontStyle()
        let underlineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 2.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 1.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = .electric
        underline.tag = 1
        self.addSubview(underline)
    }

    func changeUnderlinePosition() {
        guard let underline = self.viewWithTag(1) else {return}
        UIView.animate(withDuration: 0.3) {
            underline.frame.origin.x = (self.frame.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
        }

    }
}
