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

    var selectionColor: UIColor?
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
            let title = String.localizedStringWithFormat(String(localized: "Files (%d)", bundle: .student), fileCount)
            tabs?.setTitle(title, forSegmentAt: Tab.files.rawValue)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        drawer?.backgroundColor = .clear
        drawerControls?.backgroundColor = .backgroundLightest
        contentView?.backgroundColor = .backgroundLightest
        gripper?.backgroundColor = .backgroundMedium

        gripper?.layer.cornerRadius = 2
        updateGripperLabel(height: height)
        tabs?.setTitle(String(localized: "Comments", bundle: .student), forSegmentAt: Tab.comments.rawValue)
        tabs?.setTitle(String(localized: "Files", bundle: .student), forSegmentAt: Tab.files.rawValue)
        tabs?.setTitle(String(localized: "Rubric", bundle: .student), forSegmentAt: Tab.rubric.rawValue)
        tabs?.layer.cornerRadius = 0
        tabs?.layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async { [weak self] in
            self?.drawerControls?.roundCorners(corners: [.topLeft, .topRight], radius: 10)
            self?.tabs?.addUnderlineForSelectedSegment(self?.selectionColor)
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
        if height == 2 {
            gripper?.accessibilityLabel = String(localized: "Drawer closed", bundle: .student)
        } else if height == midDrawerHeight {
            gripper?.accessibilityLabel = String(localized: "Drawer partially opened", bundle: .student)
        } else if height == maxDrawerHeight {
            gripper?.accessibilityLabel = String(localized: "Drawer fully open", bundle: .student)
        }
    }

    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        tabs?.changeUnderlinePosition()
        if height < midDrawerHeight {
            moveTo(height: midDrawerHeight, velocity: 100)
        }
    }
}

// DRAWER MOVEMENT

extension Drawer {
    @IBAction func gripperPressed(_ sender: UIButton) {
        if height < midDrawerHeight {
            moveTo(height: midDrawerHeight, velocity: 100)
        } else if height == midDrawerHeight {
            moveTo(height: maxDrawerHeight, velocity: 100)
        } else if height > midDrawerHeight {
            moveTo(height: 2, velocity: 100)
        }
    }

    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let currentHeight = contentViewHeight?.constant else {
            return
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
            return 2
        } else if currentHeight > midDrawerHeight && velocity < 0 {
            return maxDrawerHeight
        } else if currentHeight > midDrawerHeight && velocity > 0 {
            return midDrawerHeight
        }

        return 2
    }

    func moveTo(height: CGFloat, velocity: CGFloat) {
        guard contentViewHeight?.constant != nil else {
            return
        }
        updateGripperLabel(height: height)

        UIView.animate(withDuration: 0.325, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
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
