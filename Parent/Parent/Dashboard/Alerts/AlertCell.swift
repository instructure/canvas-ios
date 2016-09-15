//
//  ObserveeAlertCell.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 2/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

import SoPersistent
import ObserverAlertKit
import SoLazy
import TooLegit

class AlertCell: UITableViewCell {

    static let iconImageDiameter: CGFloat = 36.0
    static let iconImageSubtractor: CGFloat = 15.0

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    var highlightColor = UIColor.whiteColor()
    var alert: Alert? = nil
    var session : Session? = nil

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .None
        self.accessibilityCustomActions = [UIAccessibilityCustomAction(name: "Dismiss", target: self, selector: #selector(AlertCell.dismiss(_:)))]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = selected ? highlightColor : UIColor.whiteColor()
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        contentView.backgroundColor = highlighted ? highlightColor : UIColor.whiteColor()
    }

    func dismiss(obj: AnyObject?) {
        guard let _alert = alert, _session = session else { return }

        _alert.dismiss(_session)
    }

}
