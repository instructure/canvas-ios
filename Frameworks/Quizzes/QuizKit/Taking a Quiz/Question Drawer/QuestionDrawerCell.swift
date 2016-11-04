
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import SoPretty

enum QuestionCellState: Int {
    case Flagged
    case Answered
    case Untouched
}

class QuestionDrawerCell: UITableViewCell {

    @IBOutlet var statusIconView: UIImageView!
    @IBOutlet var questionTextLabel: UILabel!
    
    class var ReuseID: String {
        return "QuestionDrawerCell"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "QuestionDrawerCell", bundle: NSBundle(forClass: self.classForCoder()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusIconView.tintColor = Brand.current().secondaryTintColor
    }
    
    func displayState(state: QuestionCellState) {
        switch state {
        case .Flagged:
            let flagImage = UIImage(named: "flag_selected", inBundle: NSBundle(forClass: QuestionDrawerCell.self), compatibleWithTraitCollection: nil)
            statusIconView.image = flagImage
        case .Answered:
            let checkImage = UIImage(named: "check", inBundle: NSBundle(forClass: QuestionDrawerCell.self), compatibleWithTraitCollection: nil)
            statusIconView.image = checkImage
        case .Untouched:
            statusIconView.image = nil
        }
    }
}
