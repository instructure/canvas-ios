//
// Copyright (C) 2017-present Instructure, Inc.
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

class DropdownAnswersPickerView: UIView {
    static var Nib: UINib {
        return UINib(nibName: "DropdownAnswersPickerView", bundle: Bundle(for: self.classForCoder()))
    }

    @IBOutlet weak var picker: UIPickerView!

    private(set) var answers: [Answer] = []

    static func new(answers: [Answer]) -> DropdownAnswersPickerView {
        let picker = DropdownAnswersPickerView.Nib.instantiate(withOwner: self, options: nil).first as! DropdownAnswersPickerView
        picker.answers = answers
        return picker
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        picker.delegate = self
        picker.dataSource = self
    }
}

extension DropdownAnswersPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return answers.count
    }
}
