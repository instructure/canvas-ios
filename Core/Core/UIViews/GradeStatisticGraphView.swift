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

public class GradeStatisticGraphView: UIView {
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!

    @IBOutlet weak var minPossibleBar: UIView!
    @IBOutlet weak var maxPossibleBar: UIView!

    @IBOutlet weak var graphArea: UIView!

    @IBOutlet weak var minConstraint: NSLayoutConstraint!
    @IBOutlet weak var maxConstraint: NSLayoutConstraint!
    @IBOutlet weak var yourScoreConstraint: NSLayoutConstraint!
    @IBOutlet weak var meanConstraint: NSLayoutConstraint!

    // These are here just for tests
    @IBOutlet weak var leftBoundView: UIView!
    @IBOutlet weak var rightBoundView: UIView!
    @IBOutlet weak var minBarView: UIView!
    @IBOutlet weak var maxBarView: UIView!
    @IBOutlet weak var meanBarView: UIView!

    @IBOutlet private var lines: [UIView]!

    @IBOutlet weak var yourScoreView: UIView!

    // State: These are computed when update() is called
    // and are used in layoutSubviews so we can resize
    // even if update isn't called.
    private var minPercent: CGFloat?
    private var maxPercent: CGFloat?
    private var avgPercent: CGFloat?
    private var studentPercent: CGFloat?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()

        yourScoreView.backgroundColor = Brand.shared.primary
        yourScoreView.layer.cornerRadius = 8.0
        for line in lines {
            line.layer.cornerRadius = 1.0
        }
    }

    public override func layoutSubviews() {
        if let minPercent = minPercent, let avgPercent = avgPercent, let maxPercent = maxPercent, let studentPercent = studentPercent {
            let usableWidth = frame.width - 48.0 - 2.0 // subtract 2 for half width of the outermost bars

            minConstraint.constant = usableWidth * minPercent
            meanConstraint.constant = usableWidth * avgPercent
            maxConstraint.constant = usableWidth * maxPercent
            yourScoreConstraint.constant = usableWidth * studentPercent
        }
        super.layoutSubviews()
    }
    public func update(_ assignment: Assignment) {
        setupGraph(assignment: assignment)
    }

    func setupGraph(assignment: Assignment) {
        guard let stats = assignment.scoreStatistics, let points_possible = assignment.pointsPossible, let score = assignment.viewableScore, points_possible > 0 else {
            isHidden = true
            return
        }
        isHidden = false

        let allowedInterval = 0 ... points_possible
        let boundedMin = allowedInterval.clamp(stats.min)
        let boundedMax = allowedInterval.clamp(stats.max)
        let boundedMean = allowedInterval.clamp(stats.mean)
        let boundedScore = allowedInterval.clamp(score)

        let possible = CGFloat(points_possible)

        // Store percents, they will be used to fix constraints in layoutSubviews,
        // even as the view changes
        minPercent = (CGFloat(boundedMin) / possible)
        maxPercent = (CGFloat(boundedMax) / possible)
        avgPercent = (CGFloat(boundedMean) / possible)
        studentPercent = (CGFloat(boundedScore) / possible)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1

        minLabel.text = String.localizedStringWithFormat(
            String(localized: "Low: %@", bundle: .core),
            formatter.string(from: NSNumber(value: stats.min)) ?? ""
        )
        averageLabel.text = String.localizedStringWithFormat(
            String(localized: "Mean: %@", bundle: .core),
            formatter.string(from: NSNumber(value: stats.mean)) ?? ""
        )
        maxLabel.text = String.localizedStringWithFormat(
            String(localized: "High: %@", bundle: .core),
            formatter.string(from: NSNumber(value: stats.max)) ?? ""
        )

        // We want the layout to update NOW -- don't wait for next cycle
        setNeedsLayout()
        layoutIfNeeded()
    }
}
