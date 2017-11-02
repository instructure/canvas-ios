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
