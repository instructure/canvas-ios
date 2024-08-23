//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import SwiftUI

struct MultiPickerView: UIViewRepresentable {
    var content: [[String]]
    var widths: [CGFloat]
    var alignments: [NSTextAlignment]

    @Binding var selections: [Int]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<MultiPickerView>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)

        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<MultiPickerView>) {

        for i in 0 ..< self.selections.count {
            view
                .selectRow(self.selections[i],
                           inComponent: i,
                           animated: false)
        }

        context.coordinator.view = self
    }
}

extension MultiPickerView {

    class Coordinator: NSObject,
                       UIPickerViewDataSource,
                       UIPickerViewDelegate {

        var view: MultiPickerView

        init(_ view: MultiPickerView) {
            self.view = view
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return view.content.count
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {

            let margins = pickerView.directionalLayoutMargins
            let horizontalMargins = margins.leading + margins.trailing

            let fullWidth = pickerView.frame.width - horizontalMargins
            let width = view.widths[safeIndex: component] ?? view.widths.last ?? 1

            let total: CGFloat
            if view.widths.isEmpty {
                total = CGFloat(view.content.count)
            } else {
                total = view.widths.reduce(0, { $0 + $1 })
            }

            let ratio = width / total

            return fullWidth * ratio
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return view.content[component].count
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

            let label = view as? RowLabel ?? RowLabel()

            label.textLabel.text = self.view.content[component][row]
            label.textLabel.textAlignment = self.view.alignments[safeIndex: component] ?? .natural

            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            view.selections[component] = row
        }
    }
}

private class RowLabel: UIView {
    required init?(coder: NSCoder) { nil }

    let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
}

#Preview {
    @State var selection: [Int] = [0, 0]

    return MultiPickerView(
        content: [
            (1 ... 400).map({ String($0) }),
            ["Daily", "Weekly", "Monthly", "Yearly"]
        ],
        widths: [3, 7],
        alignments: [.right, .left],
        selections: $selection
    )
}
