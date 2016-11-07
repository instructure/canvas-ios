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
import Foundation

let gpaNumberFormatter: (Double) -> String = {
    let formatter = NSNumberFormatter()
    formatter.alwaysShowsDecimalSeparator = true
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 1
    formatter.minimumIntegerDigits = 1
    
    return { n in formatter.stringFromNumber(n)! }
}()

private let passFailTitles = [
    NSLocalizedString("Pass", tableName: nil, bundle: .swiftGrader, value: "Pass", comment: "'Pass' grade for a pass/fail assignment"),
    NSLocalizedString("Fail", tableName: nil, bundle: .swiftGrader, value: "Fail", comment: "'Fail' grade for a pass/fail assignment")
]

private let letterTitles = [
    NSLocalizedString("A" , tableName: nil, bundle: .swiftGrader, value: "A", comment: "A letter grade"),
    NSLocalizedString("A-", tableName: nil, bundle: .swiftGrader, value: "A-", comment: "A- letter grade"),
    NSLocalizedString("B+", tableName: nil, bundle: .swiftGrader, value: "B+", comment: "B+ letter grade"),
    NSLocalizedString("B", tableName: nil, bundle: .swiftGrader, value: "B", comment: "B letter grade"),
    NSLocalizedString("B-", tableName: nil, bundle: .swiftGrader, value: "B-", comment: "B- letter grade"),
    NSLocalizedString("C+", tableName: nil, bundle: .swiftGrader, value: "C+", comment: "C+ letter grade"),
    NSLocalizedString("C", tableName: nil, bundle: .swiftGrader, value: "C", comment: "C letter grade"),
    NSLocalizedString("C-", tableName: nil, bundle: .swiftGrader, value: "C-", comment: "C- letter grade"),
    NSLocalizedString("D+", tableName: nil, bundle: .swiftGrader, value: "D+", comment: "D+ letter grade"),
    NSLocalizedString("D", tableName: nil, bundle: .swiftGrader, value: "D", comment: "D letter grade"),
    NSLocalizedString("D-", tableName: nil, bundle: .swiftGrader, value: "D-", comment: "D- letter grade"),
    NSLocalizedString("F", tableName: nil, bundle: .swiftGrader, value: "F", comment: "F letter grade")
]

extension UILabel {
    func adjustSize(biggestString: String) {
        font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody).monospacedDigitFont
        text = biggestString
        sizeToFit()
        bounds.size.width += 2
    }
}

private func bigString(maxPoints: Double, includeDecimal: Bool = true) -> String {
    let digitCount = Int(max(log10(maxPoints), 0.0) + 1)
    var bigString = (0..<digitCount)
        .map { _ in "8" }
        .joinWithSeparator("")
    
    if includeDecimal {
        bigString += ".8"
    }
    return bigString
}

class GradePicker: UIControl {
    enum ScoringType {
        case points(Double)
        case percentage
        case passFail
        case letter
        case gpa
        case none
        
        var numberOfScores: Int {
            switch self {
            case .points(let max):  return Int(max + 1) // include 0 and `max`
            case .percentage:       return 101
            case .passFail:         return passFailTitles.count
            case .letter:           return letterTitles.count
            case .gpa:              return 41 // 0.0 ... 4.0
            case .none:             return 0
            }
        }
        
        func view(scoreIndex scoreIndex: Int, reusing reusableView: UIView?) -> UIView {
            let label = (reusableView as? UILabel) ?? UILabel()
            switch self {
            case .points(let maxPoints):
                label.adjustSize(bigString(maxPoints, includeDecimal: false))
                label.text = "\(scoreIndex)"
                label.textAlignment = .Right
                
            case .percentage:
                label.adjustSize(bigString(100, includeDecimal: false) + "%")
                label.text = "\(scoreIndex)%"
                label.textAlignment = .Right
                
            case .passFail:
                label.adjustSize("FAILPASSWHATABOUTGERMAN?")
                label.textAlignment = .Center
                label.text = passFailTitles[scoreIndex]
                
            case .letter:
                label.adjustSize("C+.")
                label.textAlignment = .Left
                label.text = letterTitles[scoreIndex]
                
            case .gpa:
                label.adjustSize(bigString(4.0))
                label.textAlignment = .Right
                label.text = gpaNumberFormatter(Double(scoreIndex)/10.0)
                
            case .none:
                label.text = ""
            }
            
            return label
        }
    }
    
    @IBOutlet var picker: UIPickerView!
    
    var scoringType: ScoringType = .letter {
        didSet {
            picker.reloadAllComponents()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picker.delegate = self
        picker.dataSource = self
    }
}


extension GradePicker: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return scoringType.numberOfScores
    }
}

extension GradePicker: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        return scoringType.view(scoreIndex: row, reusing: view)
    }
}
