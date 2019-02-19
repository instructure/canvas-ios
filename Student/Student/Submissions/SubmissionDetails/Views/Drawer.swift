//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import QuartzCore
import Core

class Drawer: UIView {

    @IBOutlet weak var drawer: UIView?
    @IBOutlet weak var drawerControls: UIView?
    @IBOutlet weak var gripper: UIView?
    @IBOutlet weak var tabs: UISegmentedControl?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint?

    var height = CGFloat(integerLiteral: 0)
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.loadView(for: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.clear
        drawer?.backgroundColor = UIColor.clear

        gripper?.layer.cornerRadius = 2
        tabs?.setTitle(NSLocalizedString("Comments", bundle: .student, comment: ""), forSegmentAt: 0)
        tabs?.setTitle(NSLocalizedString("Files", bundle: .student, comment: ""), forSegmentAt: 1)
        tabs?.setTitle(NSLocalizedString("Rubric", bundle: .student, comment: ""), forSegmentAt: 2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // the subviews at this point haven't always been laid out completely
        // This caused only one corner to be rounded and not the other
        // This fixes that issue
        DispatchQueue.main.async { [weak self] in
            self?.drawerControls?.roundCorners(corners: [.topLeft, .topRight], radius: 10)
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
}

// DRAWER MOVEMENT

extension Drawer {
    @IBAction func gripperPressed(_ sender: UIButton) {
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
}
