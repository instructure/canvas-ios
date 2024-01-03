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

    public static func showDatePicker(for date: Binding<Date?>, minDate: Date? = nil, maxDate: Date? = nil, from controller: UIViewController) {
        let env = AppEnvironment.shared
        let picker = CoreHostingController(CoreDatePickerActionSheetCard(selection: date, minDate: minDate, maxDate: maxDate))
        picker.view.backgroundColor = UIColor.clear
        env.router.show(picker,
                        from: controller,
                        options: .modal(.overFullScreen,
                                        isDismissable: true,
                                        embedInNav: false,
                                        addDoneButton: false,
                                        animated: false))
    }

    public static func showDatePicker(for date: Binding<Date?>, minDate: Date? = nil, maxDate: Date? = nil, from controller: WeakViewController) {
        self.showDatePicker(for: date, minDate: minDate, maxDate: maxDate, from: controller.value)
    }
}

public struct CoreDatePickerActionSheetCard: View {
    @Environment(\.viewController) var controller
    @State private var grayViewOpacity = 0.0
    @State private var animationOffset = 300.0
    @State private var offset = UIScreen.main.bounds.height
    @State private var selectedDate: Date
    @Binding private var selectionDate: Date?

    private var pickerDateRange: ClosedRange<Date>

    public init(selection: Binding<Date?>, minDate: Date?, maxDate: Date?) {
        _selectionDate = selection
        _selectedDate = State<Date>(initialValue: selection.wrappedValue ?? Clock.now)
        pickerDateRange = CoreDatePickerActionSheetCard.dateRange(with: minDate, max: maxDate)
    }

    public var body: some View {
        ZStack {
            grayView
                .opacity(grayViewOpacity)
                .animation(.easeOut(duration: 0.2), value: grayViewOpacity)
                .onTapGesture {
                    dismissPresentation()
                }
            VStack {
                Spacer()
                itemsView
                    .background(Color.backgroundLightest)
                    .animation(.easeOut(duration: 0.2), value: animationOffset)
                    .offset(x: 0.0, y: animationOffset)
                    .onAppear {
                        self.animationOffset = 0.0
                    }
            }.ignoresSafeArea()
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
                    Text("Cancel", bundle: .core)
                        .font(.regular17)
                        .foregroundStyle(
                            Color(uiColor: Brand.shared.primary.darkenToEnsureContrast(against: .backgroundLightest))
                        )
                }
                Spacer()
                Button {
                    selectionDate = pickerDateRange.clamp(selectedDate)
                    dismissPresentation()
                } label: {
                    Text("Done", bundle: .core)
                        .font(.regular17)
                        .foregroundStyle(
                            Color(uiColor: Brand.shared.primary.darkenToEnsureContrast(against: .backgroundLightest))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 0)

            DatePicker(selection: $selectedDate, in: pickerDateRange) {}
            .padding(.bottom, 14)
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
        }
    }

    private var grayView: some View {
        Rectangle()
            .frame(width: .infinity,
                   height: .infinity)
            .foregroundColor(.black)
            .ignoresSafeArea()
    }

    static func dateRange(with min: Date?, max: Date?) -> ClosedRange<Date> {
        if let min = min, let max = max, min < max {
            return min...max
        }

        if let min = min, max == nil {
            return min...min.addYears(2)
        }

        if let max = max, min == nil {
            return max.addYears(-2)...max
        }

        return Clock.now.addYears(-1)...Clock.now.addYears(1)
    }

    private func dismissPresentation() {
        animationOffset = 300
        grayViewOpacity = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.controller.value.dismiss(animated: false)
        }
    }
}

#if DEBUG

struct CoreDatePickerActionSheetCard_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            VStack {
                CoreDatePickerActionSheetCard(selection: .constant(Date()), minDate: Clock.now, maxDate: Clock.now.addDays(5))
            }.preferredColorScheme($0)
        }
    }
}

#endif
