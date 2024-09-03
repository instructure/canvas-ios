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

enum PickerTextAlignment {
    case leading, center, trailing, natural

    func toLabelTextAlignment() -> NSTextAlignment {
        let direction = Locale.current.language.characterDirection
        let isRTL = direction == .rightToLeft

        switch self {
        case .leading:
            return isRTL ? .right : .left
        case .trailing:
            return isRTL ? .left : .right
        case .center:
            return .center
        case .natural:
            return .natural
        }
    }
}

struct MultiPickerView<Value1, Value2>: UIViewRepresentable where Value1: Equatable, Value2: Equatable {
    let content1: [Value1]
    let titleKey1: KeyPath<Value1, String>
    var title1GivenSelected2: ((Value1, Value2) -> String)?
    @Binding var selection1: Value1

    let content2: [Value2]
    let titleKey2: KeyPath<Value2, String>
    var title2GivenSelected1: ((Value2, Value1) -> String)?
    @Binding var selection2: Value2

    let widths: [CGFloat]
    let alignments: [PickerTextAlignment]

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
        for component in 0 ..< view.numberOfComponents {
            if let index = selectionIndex(for: component) {
                view.selectRow(index, inComponent: component, animated: false)
            }
        }
        context.coordinator.view = self
    }
}

private extension MultiPickerView {

    func contentCount(for component: Int) -> Int {
        switch component {
        case 0:
            return content1.count
        case 1:
            return content2.count
        default:
            return 0
        }
    }

    func widthRatio(for component: Int) -> CGFloat {
        let width = widths[safeIndex: component] ?? widths.prefix(2).last ?? 1

        let total: CGFloat
        if widths.isEmpty {
            total = 2
        } else {
            total = widths.prefix(2).reduce(0, { $0 + $1 })
        }

        return width / total
    }

    func title(forRow row: Int, ofComponent component: Int) -> String? {
        switch component {
        case 0:
            if let titleBlock = title1GivenSelected2, let value1 = content1[safeIndex: row] {
                return titleBlock(value1, selection2)
            } else {
                return content1[safeIndex: row].flatMap({ $0[keyPath: titleKey1] })
            }
        case 1:
            if let titleBlock = title2GivenSelected1, let value2 = content2[safeIndex: row] {
                return titleBlock(value2, selection1)
            } else {
                return content2[safeIndex: row].flatMap({ $0[keyPath: titleKey2] })
            }
        default:
            return nil
        }
    }

    func alignment(for component: Int) -> NSTextAlignment {
        return (alignments[safeIndex: component] ?? .natural).toLabelTextAlignment()
    }

    func selectionIndex(for component: Int) -> Int? {
        switch component {
        case 0:
            return content1.firstIndex(of: selection1)
        case 1:
            return content2.firstIndex(of: selection2)
        default:
            return nil
        }
    }

    func setSelection(to index: Int, for component: Int) {
        switch component {
        case 0:
            selection1 = content1[index]
        case 1:
            selection2 = content2[index]
        default:
            return
        }
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
            return 2
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            let margins = pickerView.directionalLayoutMargins
            let horizontalMargins = margins.leading + margins.trailing
            let fullWidth = pickerView.frame.width - horizontalMargins
            return fullWidth * view.widthRatio(for: component)
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return view.contentCount(for: component)
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

            let label = view as? RowLabel ?? RowLabel()
            label.textLabel.text = self.view.title(forRow: row, ofComponent: component)
            label.textLabel.textAlignment = self.view.alignment(for: component)

            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            view.setSelection(to: row, for: component)

            if view.title2GivenSelected1 != nil, component == 0 {
                pickerView.reloadComponent(1)
            }

            if view.title1GivenSelected2 != nil, component == 1 {
                pickerView.reloadComponent(0)
            }
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

#if DEBUG

#Preview {
    struct PreviewView: View {
        @State var selection1: Int = 5
        @State var selection2: String = "Monthly"

        var body: some View {
            MultiPickerView(
                content1: (1 ... 400).map({ $0 }),
                titleKey1: \.description,
                selection1: $selection1,

                content2: ["Daily", "Weekly", "Monthly", "Yearly"],
                titleKey2: \.self,
                title2GivenSelected1: { val2, val1 in
                    let suffix = val1 > 1 ? "s" : ""
                    return val2 + suffix
                },
                selection2: $selection2,

                widths: [3, 7],
                alignments: [.trailing, .leading]
            )
            .onChange(of: selection1) { newValue in
                print("Interval: \(newValue)")
            }
            .onChange(of: selection2) { newValue in
                print("Frequency: \(newValue)")
            }
        }
    }

    return PreviewView()
}

#endif
