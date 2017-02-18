//
//  DropdownAnswersPickerView.swift
//  Quizzes
//
//  Created by Nathan Armstrong on 2/10/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
