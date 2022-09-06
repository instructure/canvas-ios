//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI

public struct CoreDatePicker {

    public static func pickDate(for date: Binding<Date?>, with dateRange: ClosedRange<Date>? = nil, from controller: UIViewController) {
        let env = AppEnvironment.shared
        let dateRange = dateRange ?? Date().addYears(-1)...Date().addYears(1)
        let picker = CoreHostingController(CoreDatePickerActionSheetCard(selection: date, dateRange: dateRange))
        picker.view.backgroundColor = UIColor.clear
        env.router.show(picker,
                        from: controller,
                        options: .modal(.overFullScreen,
                                        isDismissable: true,
                                        embedInNav: false,
                                        addDoneButton: false))
    }

    public static func pickDate(for date: Binding<Date?>, from controller: WeakViewController) {
        self.pickDate(for: date, from: controller.value)
    }
}

public struct CoreDatePickerActionSheetCard: View {
    @Environment(\.viewController) var controller
    @State private var grayViewOpacity = 0.0
    @State private var animationOffset = 300.0
    @State private var offset = UIScreen.main.bounds.height
    @State private var selectedDate: Date
    @Binding private var selectionDate: Date?

    private var grayView = CoreDatePickerGreyOutFocusOfView()
    private let heightToDisappear = UIScreen.main.bounds.height
    private let backgroundColor = Color.backgroundLightest

    private var pickerDateRange: ClosedRange<Date>

    public init(selection: Binding<Date?>, dateRange: ClosedRange<Date> = Clock.now...Clock.now.addYears(1)) {
        _selectionDate = selection
        _selectedDate = State<Date>(initialValue: selection.wrappedValue ?? Date())
        pickerDateRange = dateRange
    }

    public var body: some View {
        ZStack {
            grayView
                .opacity(grayViewOpacity)
                .animation(.easeInOut.delay(0.2), value: grayViewOpacity)
                .onTapGesture {
                    dismissPresentation()
                }
            VStack {
                Spacer()
                itemsView
                    .background(backgroundColor)
                    .animation(.easeInOut.delay(0.2), value: animationOffset)
                    .offset(x: 0.0, y: animationOffset)
                    .onAppear {
                        self.animationOffset = 0.0
                    }
            }
        }
        .onAppear {
            grayViewOpacity = 0.5
        }
    }

    private var itemsView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button {
                    dismissPresentation()
                } label: {
                    Text("Cancel").font(.regular17)
                }
                Spacer()
                Button {
                    selectionDate = selectedDate
                    dismissPresentation()
                } label: {
                    Text("Done").font(.regular17)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            DatePicker(selection: $selectedDate, in: pickerDateRange) {}
            .padding(.bottom, 14)
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
        }
    }

    func dismissPresentation() {
        animationOffset = 300
        grayViewOpacity = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.controller.value.dismiss(animated: false)
        }
    }
}

struct CoreDatePickerActionSheetCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CoreDatePickerActionSheetCard(selection: .constant(Date()), dateRange: Clock.now...Clock.now.addDays(5))
        }
    }
}
