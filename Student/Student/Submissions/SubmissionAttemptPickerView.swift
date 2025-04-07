//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import UIKit

class SubmissionAttemptPickerView: UIView {
    @IBOutlet unowned var divider: DividerView!
    @IBOutlet unowned var label: UILabel!
    @IBOutlet unowned var pickerButton: DynamicButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
        setup()
    }

    init() {
        super.init(frame: .zero)
        loadFromXib()
        setup()
    }

    private func setup() {
        backgroundColor = .backgroundLightest
        label.text = nil
        pickerButton.setTitle(nil, for: .normal)
        isAccessibilityElement = true
    }

    func hideDivider() {
        divider.isHidden = true
    }

    func updateLabel(text: String) {
        label?.text = text
        updateAccessibilty()
    }

    func updatePickerButton(isActive: Bool, attemptDate: String, items: [UIAction]) {
        pickerButton.isEnabled = isActive
        pickerButton.setTitle(attemptDate, for: .normal)
        pickerButton.setTitleColor(.textDark, for: .normal)
        pickerButton.setTitleColor(.textDark, for: .disabled)

        var buttonConfig = pickerButton.configuration ?? .plain()
        buttonConfig.contentInsets = {
            var result = buttonConfig.contentInsets
            result.trailing = 0
            return result
        }()
        buttonConfig.titleTextAttributesTransformer = .init { attributes in
            var result = attributes
            result.font = UIFont.scaledNamedFont(.regular14)
            return result
        }

        // Since submissions can't be deleted we don't have to handle the case of
        // turning the active picker to inactive
        if isActive {
            buttonConfig.imagePlacement = .trailing
            buttonConfig.imagePadding = 6
            buttonConfig.image = .arrowOpenDownSolid
                .scaleTo(.init(width: 14, height: 14))
                .withRenderingMode(.alwaysTemplate)
            buttonConfig.indicator = .none

            pickerButton.changesSelectionAsPrimaryAction = true
            pickerButton.showsMenuAsPrimaryAction = true
            pickerButton.menu = UIMenu(children: items)
        } else {
            pickerButton.accessibilityTraits = .staticText
        }

        pickerButton?.configuration = buttonConfig

        updateAccessibilty()
    }

    private func updateAccessibilty() {
        guard let attempt = label?.text,
              let date = pickerButton.title(for: .normal)
        else { return }

        let format = String(localized: "%1$@, submitted on %2$@", bundle: .student, comment: "Attempt 30, submitted on 2025. Feb 6. at 18:21")
        accessibilityLabel = String.localizedStringWithFormat(format, attempt, date)
        if pickerButton.menu != nil {
            accessibilityTraits = [.button]
            accessibilityValue = String(localized: "Collapsed", bundle: .student)
            accessibilityHint = String(localized: "Double tap to select attempt", bundle: .student)
        } else {
            accessibilityTraits = [.staticText]
            accessibilityValue = nil
            accessibilityHint = nil
        }
    }
}
