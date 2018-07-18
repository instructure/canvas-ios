//
// Copyright (C) 2016-present Instructure, Inc.
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


enum QuestionCellState: Int {
    case flagged
    case answered
    case untouched
}

class QuestionDrawerCell: UITableViewCell {

    @IBOutlet var statusIconView: UIImageView!
    @IBOutlet var questionTextLabel: UILabel!
    
    class var ReuseID: String {
        return "QuestionDrawerCell"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "QuestionDrawerCell", bundle: Bundle(for: self.classForCoder()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusIconView.tintColor = Brand.current.secondaryTintColor
    }
    
    func displayState(_ state: QuestionCellState) {
        switch state {
        case .flagged:
            let flagImage = UIImage(named: "flag_selected", in: Bundle(for: QuestionDrawerCell.self), compatibleWith: nil)
            statusIconView.image = flagImage
        case .answered:
            let checkImage = UIImage(named: "quiz-check", in: Bundle(for: QuestionDrawerCell.self), compatibleWith: nil)
            statusIconView.image = checkImage
        case .untouched:
            statusIconView.image = nil
        }
    }
}
