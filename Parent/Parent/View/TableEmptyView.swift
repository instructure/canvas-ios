//
//  TableViewEmptyView.swift
//  Parent
//
//  Created by Brandon Pluim on 3/31/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import SoLazy

class TableEmptyView: UIView {

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var textLabel: UILabel!

    static func nibView() -> TableEmptyView {
        guard let view = NSBundle(forClass: TableEmptyView.self).loadNibNamed("TableEmptyView", owner: self, options: nil)!.first as? TableEmptyView else {
            ❨╯°□°❩╯⌢"View loaded from NIB is not a TableEmptyView"
        }

        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
    }

}
