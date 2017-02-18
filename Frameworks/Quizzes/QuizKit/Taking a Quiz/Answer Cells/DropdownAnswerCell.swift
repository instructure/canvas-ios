//
//  DropdownAnswerCell.swift
//  Quizzes
//
//  Created by Nathan Armstrong on 2/9/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

@IBDesignable
class TriangleView: UIView {
    var triangleColor: UIColor? {
        didSet {
            triangleLayer.fillColor = triangleColor?.cgColor
        }
    }

    private let triangleLayer = CAShapeLayer()

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()

        let origin = CGPoint(x: self.bounds.size.width/2, y: 0)
        path.move(to: origin)
        path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
        path.addLine(to: origin)

        triangleLayer.path = path.cgPath

        self.layer.addSublayer(triangleLayer)
    }
}

@IBDesignable
class DropdownButton: UIControl {
    struct Colors {
        static let border = UIColor.lightGray
        static let borderSelected = #colorLiteral(red: 0.1497211456, green: 0.6432420015, blue: 0.891037643, alpha: 1)
        static let arrows = UIColor.black
    }

    let valueLabel = UILabel()

    let topArrow = TriangleView()
    let bottomArrow = TriangleView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    func setUp() {
        layer.borderColor = DropdownButton.Colors.border.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6

        // title
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)

        // top arrow
        topArrow.triangleColor = .black
        topArrow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topArrow)

        // bottom arrow
        bottomArrow.triangleColor = .black
        bottomArrow.translatesAutoresizingMaskIntoConstraints = false
        bottomArrow.layer.setAffineTransform(CGAffineTransform(scaleX: 1, y: -1))
        addSubview(bottomArrow)

        // tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    func tapped() {
        sendActions(for: .touchUpInside)
        self.isSelected = true
    }

    func dismissed() {
        self.isSelected = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // title
        NSLayoutConstraint.activate([
            valueLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        ])

        // Arrows
        let arrowSize: CGFloat = 6
        let arrowVerticalSpace: CGFloat = 1
        let arrowTrailingConstant: CGFloat = -10

        /// top arrow
        NSLayoutConstraint.activate([
            topArrow.widthAnchor.constraint(equalToConstant: arrowSize),
            topArrow.heightAnchor.constraint(equalToConstant: arrowSize),
            topArrow.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -((arrowSize/2) + arrowVerticalSpace)),
            topArrow.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: arrowTrailingConstant),
            topArrow.leadingAnchor.constraint(greaterThanOrEqualTo: valueLabel.trailingAnchor, constant: 10)
        ])

        /// bottom arrow
        NSLayoutConstraint.activate([
            bottomArrow.widthAnchor.constraint(equalToConstant: arrowSize),
            bottomArrow.heightAnchor.constraint(equalToConstant: arrowSize),
            bottomArrow.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: (arrowSize/2) + arrowVerticalSpace),
            bottomArrow.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: arrowTrailingConstant)
        ])
    }
}

class DropdownAnswerCell: UITableViewCell {
    class var ReuseID: String {
        return "DropdownAnswerCellReuseID"
    }

    static var Nib: UINib {
        return UINib(nibName: "DropdownAnswerCell", bundle: Bundle(for: self.classForCoder()))
    }

    @IBOutlet weak var dropdownLabel: UILabel!
    @IBOutlet weak var dropdownButton: DropdownButton!

    var dropdownButtonTapped: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()

        dropdownButton.addTarget(self, action: #selector(dropdownAction), for: .touchUpInside)
    }

    func dropdownAction() {
        dropdownButtonTapped?()
    }
}
