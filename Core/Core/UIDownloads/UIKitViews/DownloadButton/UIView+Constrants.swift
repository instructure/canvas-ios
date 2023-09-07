import UIKit
@available(iOS 13.0, *)
extension UIView {

    @discardableResult
    func constraint(
        attribute: NSLayoutConstraint.Attribute,
        relation: NSLayoutConstraint.Relation = .equal,
        toItem: Any? = nil,
        toAttribute: NSLayoutConstraint.Attribute = .notAnAttribute,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0
    ) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: relation,
            toItem: toItem,
            attribute: toAttribute,
            multiplier: multiplier,
            constant: constant
        )
        return constraint
    }

    func pinToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = constraint(attribute: .top, toItem: superview, toAttribute: .top)
        let bottomConstraint = constraint(attribute: .bottom, toItem: superview, toAttribute: .bottom)
        let leadingConstraint = constraint(attribute: .leading, toItem: superview, toAttribute: .leading)
        let trailingConstraint = constraint(attribute: .trailing, toItem: superview, toAttribute: .trailing)
        NSLayoutConstraint.activate([trailingConstraint, topConstraint, leadingConstraint, bottomConstraint])
    }
    func pinToSuperview(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = constraint(
            attribute: .top,
            toItem: superview,
            toAttribute: .top,
            constant: constant
        )
        let bottomConstraint = constraint(
            attribute: .bottom,
            toItem: superview,
            toAttribute: .bottom,
            constant: -constant
        )
        let leadingConstraint = constraint(
            attribute: .leading,
            toItem: superview,
            toAttribute: .leading,
            constant: -constant
        )
        let trailingConstraint = constraint(
            attribute: .trailing,
            toItem: superview,
            toAttribute: .trailing,
            constant: constant
        )
        NSLayoutConstraint.activate([trailingConstraint, topConstraint, leadingConstraint, bottomConstraint])
    }

    func centerToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = constraint(attribute: .centerX, toItem: superview, toAttribute: .centerX)
        let centerYConstraint = constraint(attribute: .centerY, toItem: superview, toAttribute: .centerY)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
    }

}
