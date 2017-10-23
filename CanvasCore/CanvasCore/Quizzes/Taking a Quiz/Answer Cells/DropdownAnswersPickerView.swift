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
