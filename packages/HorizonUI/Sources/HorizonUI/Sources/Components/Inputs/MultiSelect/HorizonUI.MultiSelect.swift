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

import Flow
import Observation
import SwiftUI

extension HorizonUI {
    public struct MultiSelect: View {
        // MARK: Dependencies

        private let disabled: Bool
        private let error: String?
        private let label: String?
        private let options: [String]
        private var optionsFiltered: [String] {
            options.filter { !selections.contains($0) }
        }
        private let placeholder: String?
        private let zIndex: Double
        @Binding private var selections: [String]

        // MARK: Properties

        private var bodyHeight: CGFloat {
            textInputMeasuredHeight + labelMeasuredHeight + errorHeight
        }

        // The computed height of a single option
        @State private var displayedOptionHeight: CGFloat = 0

        // Computed height of the container for all options
        private var displayedOptionsHeight: CGFloat {
            if !focused {
                return 0
            }
            return max(
                loading ? spinnerHeight : 0,
                min(displayedOptionHeight * CGFloat(options.count) + .huiSpaces.space4, 300)
            )
        }

        // The computed height of the error text
        @State private var errorHeight: CGFloat = 0

        @Binding private var focused: Bool

        // The computed height of the label
        @State private var labelMeasuredHeight: CGFloat = 0

        @Binding private var loading: Bool

        @State private var spinnerHeight = 0.0

        // The container height for the text input. This is used to fix the height
        // of the entire component so when the options are displayed, it doesnt
        // push the content below it down
        @State private var textInputMeasuredHeight: CGFloat = 0

        // The text in the TextField
        @Binding private var textInput: String

        @FocusState private var textFieldFocusState: Bool

        // MARK: - Init

        public init(
            selections: Binding<[String]>,
            focused: Binding<Bool>,
            label: String? = nil,
            textInput: Binding<String>,
            options: [String],
            loading: Binding<Bool>,
            disabled: Bool = false,
            placeholder: String? = nil,
            error: String? = nil,
            zIndex: Double = 101
        ) {
            self._selections = selections
            self._focused = focused
            self.label = label
            self._textInput = textInput
            self.options = options
            self._loading = loading
            self.disabled = disabled
            self.placeholder = placeholder
            self.error = error
            self.zIndex = zIndex
        }

        public var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    labelText
                    textFieldAndChevron
                }
                .onTapGesture(perform: onTapText)

                ZStack(alignment: .top) {
                    errorText
                    dropDownOptionsWithSpinner
                        .zIndex(zIndex)
                }
                .padding(.horizontal, 3)
            }
            .background(.clear)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: bodyHeight, alignment: .top)
            .padding(1)
            .zIndex(zIndex)
        }

        // MARK: - Private
        @ViewBuilder
        private var errorText: some View {
            if let error = error {
                HStack {
                    HorizonUI.icons.error
                        .frame(width: .huiSpaces.space16, height: .huiSpaces.space16)
                        .foregroundColor(.huiColors.text.error)
                    Text(error)
                        .huiTypography(.p2)
                        .foregroundColor(.huiColors.text.error)
                }
                .background {
                    GeometryReader { geometry in
                        HStack {}
                            .onAppear {
                                errorHeight = geometry.size.height
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, .huiSpaces.space8)
                .padding(.top, .huiSpaces.space2)
            }
        }

        @ViewBuilder
        private var labelText: some View {
            if let label = label {
                Text(label)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, .huiSpaces.space8)
                    .huiTypography(.labelLargeBold)
                    .foregroundColor(.huiColors.text.body)
                    .background {
                        GeometryReader { geometry in
                            HStack {}
                                .onAppear {
                                    labelMeasuredHeight = geometry.size.height
                                }
                        }
                    }
            }
        }

        // MARK: - DropDown Components
        private var dropDownOptionsWithSpinner: some View {
            ScrollView {
                ZStack(alignment: .top) {
                    dropDownOptions
                    dropDownSpinner
                }
            }
            .background(Color.huiColors.surface.pageSecondary)
            .frame(height: displayedOptionsHeight)
            .opacity(!loading && optionsFiltered.isEmpty ? 0 : 1)
            .cornerRadius(HorizonUI.CornerRadius.level1_5.attributes.radius)
            .padding(.top, .huiSpaces.space12)
            .shadow(radius: HorizonUI.Elevations.level1.attributes.blur)
            .animation(.easeInOut, value: displayedOptionsHeight)
        }

        private var dropDownOptions: some View {
            VStack(spacing: .zero) {
                ForEach(optionsFiltered, id: \.self) { item in
                    dropDownOption(item)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.huiColors.surface.pageSecondary)
            .padding(.vertical, .huiSpaces.space4)
        }

        private var dropDownSpinner: some View {
            HorizonUI.Spinner(size: .xSmall)
                .opacity(loading ? 1 : 0)
                .padding(.vertical, HorizonUI.spaces.space8)
                .background {
                    GeometryReader { geometry in
                        HStack {}
                            .onAppear {
                                spinnerHeight = geometry.size.height
                            }
                    }
                }
        }

        private func dropDownOption(_ text: String) -> some View {
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .huiSpaces.space12)
                .padding(.vertical, .huiSpaces.space8)
                .background {
                    GeometryReader { geometry in
                        HStack {}
                            .onAppear {
                                if geometry.size.height != displayedOptionHeight {
                                    displayedOptionHeight = geometry.size.height
                                }
                            }
                    }
                }
                .background(Color.huiColors.surface.pageSecondary)
                .huiTypography(.p1)
                .onTapGesture {
                    focused = false
                    selections.append(text)
                }
        }

        // MARK: - Text Field Components

        private var textFieldAndChevron: some View {
            ZStack(alignment: .init(horizontal: .trailing, vertical: .center)) {
                textFieldAndOptions
                chevron
            }
            .padding(.huiSpaces.space4)
            .overlay(textOverlay(isOuter: true))
            .frame(maxWidth: .infinity)
            .background {
                GeometryReader { geometry in
                    HStack {}
                        .onChange(of: geometry.size.height, initial: true) {
                            textInputMeasuredHeight = geometry.size.height
                        }
                }
            }
            .onTapGesture(perform: onTapText)
            .opacity(disabled ? 0.5 : 1.0)
        }

        private var textFieldAndOptions: some View {
            VStack(alignment: .leading) {
                textField
                optionsView
            }
            .foregroundColor(textInputTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HorizonUI.spaces.space12)
            .padding(.trailing, .huiSpaces.space24)
            .overlay(textOverlay(isOuter: false))
            .background(
                HorizonUI.colors.surface.pageSecondary.clipShape(
                    RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1_5.attributes.radius)
                )
            )
        }

        @ViewBuilder
        private var textField: some View {
            if focused || selections.isEmpty {
                TextField(
                    placeholder ?? String(localized: "Filter"),
                    text: $textInput
                )
                .disabled(disabled)
                .focused($textFieldFocusState)
                .onChange(of: textFieldFocusState, initial: false) {
                    if focused != textFieldFocusState {
                        focused = textFieldFocusState
                    }
                }
                .padding(.bottom, .huiSpaces.space4)
                .huiTypography(.p1)
            }
        }

        private var chevron: some View {
            Image.huiIcons.chevronRight
                .rotationEffect(.degrees(focused ? -90 : 90))
                .padding(.trailing, .huiSpaces.space12)
                .tint(Color.huiColors.icon.default)
                .animation(.easeInOut, value: focused)
        }

        private var optionsView: some View {
            HFlow {
                ForEach(selections, id: \.self) { selection in
                    option(selection)
                }
            }
        }

        @ViewBuilder
        private func option(_ text: String) -> some View {
            HStack {
                Text(text)
                    .huiTypography(.p3)
                HorizonUI.icons.closeSmall
                    .frame(width: HorizonUI.spaces.space12, height: HorizonUI.spaces.space12)
            }
            .padding(.vertical, .huiSpaces.space4)
            .padding(.horizontal, .huiSpaces.space8)
            .background(
                HorizonUI.colors.surface.cardSecondary
                    .clipShape(
                        RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1.attributes.radius)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1.attributes.radius)
                    .stroke(
                        Color.huiColors.lineAndBorders.lineStroke,
                        lineWidth: HorizonUI.Borders.level1.rawValue
                    )
            )
            .onTapGesture {
                selections.removeAll(where: { $0 == text })
                textInput = ""
            }
        }

        // MARK: - Private Functions

        private func onTapText() {
            if disabled || optionsFiltered.isEmpty {
                return
            }
            focused = !focused
            textInput = ""
        }

        private var textInputTextColor: Color {
            selections.isEmpty ? .huiColors.text.placeholder : .huiColors.text.body
        }

        private func textOverlay(isOuter: Bool = false) -> some View {
            RoundedRectangle(cornerRadius: textOverlayCornerRadius(isOuter: isOuter))
                .stroke(
                    textOverlayStrokeColor(isOuter: isOuter),
                    lineWidth: textOverlayLineWidth(isOuter: isOuter)
                )
                .opacity(textOverlayStrokeOpacity(isOuter: isOuter))
                .animation(.easeInOut, value: focused)
                .animation(.easeInOut, value: textOverlayStrokeColor(isOuter: isOuter))
        }

        private func textOverlayCornerRadius(isOuter: Bool = false) -> CGFloat {
            HorizonUI.CornerRadius.level1_5.attributes.radius + (isOuter ? 2 : 0)
        }

        private func textOverlayStrokeOpacity(isOuter: Bool = false) -> Double {
            focused ? 1.0 : (isOuter ? 0.0 : 0.5)
        }

        private func textOverlayLineWidth(isOuter: Bool = false) -> CGFloat {
            isOuter ? HorizonUI.Borders.level2.rawValue : HorizonUI.Borders.level1.rawValue
        }

        private func textOverlayStrokeColor(isOuter: Bool = false) -> Color {
            if error?.isEmpty ?? true {
                if isOuter {
                    return .huiColors.surface.institution
                } else {
                    return .huiColors.lineAndBorders.containerStroke
                }
            }
            return .huiColors.text.error
        }
    }

    private struct VStackHeightKey: PreferenceKey {
        typealias Value = CGFloat

        static let defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

#Preview {
    @Previewable @State var selections = ["One", "Two"]
    @Previewable @State var focused = true
    @Previewable @State var textInput = "Type here"
    @Previewable @State var selectedOptionIndex = 0
    @Previewable @State var loading = false

    let options = [
        "Alphabet",
        "Backyard",
        "Country",
        "Doctor",
        "Elephant",
        "Fuzz",
        "Gorilla",
        "Horse",
        "Igloo",
        "Jelly",
        "Kangaroo",
        "Lemon",
        "Mango",
        "Nose",
        "Orange",
        "Pineapple",
        "Quilt",
        "Rabbit",
        "Squirrel",
        "Tiger",
        "Umbrella",
        "Violet",
        "Wagon",
        "Xylophone",
        "Yak",
        "Zebra"
    ]

    VStack(alignment: .leading) {
        VStack(alignment: .leading) {
            HorizonUI.MultiSelect(
                selections: $selections,
                focused: $focused,
                label: "Words of the Alphabet",
                textInput: $textInput,
                options: options,
                loading: $loading,
                disabled: false,
                placeholder: "Filter",
                error: "This is an error"
            )
            Text("Some Text Below")
        }
        .padding(.horizontal, .huiSpaces.space24)
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .background(HorizonUI.colors.surface.pagePrimary)
}
