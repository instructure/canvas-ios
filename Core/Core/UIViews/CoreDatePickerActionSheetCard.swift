//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import Combine

public struct CoreDatePickerActionSheetCard: View {
    @Environment(\.presentationMode) var presentationMode
    @State var grayViewOpacity = 0.0
    @State var animationOffset = 300.0
    @State var offset = UIScreen.main.bounds.height
    @State private var selectedDate = Date()
    @Binding var selection: Date?

    public weak var delegate: DatePickerProtocol?

    var grayView = CoreDatePickerGreyOutFocusOfView()
    var date: Date?

    public init(selectedDate: Date = Date().addMinutes(1), selection: Binding<Date?>) {
        self._selection = selection
        self.selectedDate = selectedDate
    }

    let heightToDisappear = UIScreen.main.bounds.height
    let backgroundColor = Color.backgroundLightest

    func dismissPresentation() {
        animationOffset = 300
        grayViewOpacity = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }

    var itemsView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button(action: {
                    dismissPresentation()
                }, label: {
                    Text("Cancel").font(.regular17)
                })

                Spacer()

                Button(action: {
                    selection = selectedDate
                    dismissPresentation()
                }, label: {
                    Text("Done").font(.regular17)
                })
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(width: .infinity)

            DatePicker(selection: $selectedDate) {}
            .padding(.bottom, 14)
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
        }
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
}

struct CoreDatePickerActionSheetCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CoreDatePickerActionSheetCard(selectedDate: Date(), selection: .constant(Date()))
        }
    }
}
