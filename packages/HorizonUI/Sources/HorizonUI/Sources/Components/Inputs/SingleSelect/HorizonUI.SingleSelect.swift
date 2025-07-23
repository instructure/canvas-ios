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

import Observation
import SwiftUI

extension HorizonUI {
    public struct SingleSelect: View {
        // MARK: Dependencies

        private let disabled: Bool
        private let isSearchable: Bool
        private let error: String?
        private let label: String?
        private let options: [String]
        private let placeholder: String?
        @Binding private var selection: String

        // MARK: Properties

        private var originalSelection: String
        @State private var text: String = ""
        private var bodyHeight: CGFloat {
            textInputMeasuredHeight + displayedOptionHeight + errorHeight
        }

        // The computed height of a single option
        @State private var displayedOptionHeight: CGFloat = 0

        // Computed height of the container for all options
        private var displayedOptionsHeight: CGFloat {
            focused ? min(displayedOptionHeight * CGFloat(options.count) + .huiSpaces.space4, 300) : 0
        }

        // The computed height of the error text
        @State private var errorHeight: CGFloat = 0

        @Binding private var focused: Bool
        @FocusState private var isSearchFocused: Bool

        // The computed height of the label
        @State private var labelMeasuredHeight: CGFloat = 0

        // The container height for the text input. This is used to fix the height
        // of the entire component so when the options are displayed, it doesnt
        // push the content below it down
        @State private var textInputMeasuredHeight: CGFloat = 0
        @State private var filteredItems: [String] = []

        // MARK: - Init

        public init(
            selection: Binding<String>,
            focused: Binding<Bool>,
            isSearchable: Bool = true,
            label: String? = nil,
            options: [String],
            disabled: Bool = false,
            placeholder: String? = nil,
            error: String? = nil
        ) {
            self.label = label
            self.options = options
            self._selection = selection
            self.disabled = disabled
            self.placeholder = placeholder
            self.error = error
            self._focused = focused
            self.text = selection.wrappedValue
            self.isSearchable = isSearchable
            self.filteredItems = options
            self.originalSelection = selection.wrappedValue
        }

        public var body: some View {
            VStack {
                VStack(spacing: 8) {
                    labelText
                    textInput
                }
                .onTapGesture(perform: onTapText)
                ZStack(alignment: .top) {
                    errorText
                    displayedOptions
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: bodyHeight, alignment: .top)
            .zIndex(101)
        }

        // MARK: - Private

        private var displayedOptions: some View {
            ScrollView {
                VStack(spacing: .zero) {
                    ForEach(filteredItems, id: \.self) { item in
                        displayedOption(item)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.huiColors.surface.pageSecondary)
                .padding(.vertical, .huiSpaces.space4)
            }
            .background(Color.huiColors.surface.pageSecondary)
            .frame(height: displayedOptionsHeight)
            .cornerRadius(HorizonUI.CornerRadius.level1_5.attributes.radius)
            .shadow(radius: HorizonUI.Elevations.level1.attributes.blur)
            .animation(.easeInOut, value: displayedOptionsHeight)
        }

        private func displayedOption(_ text: String) -> some View {
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
                    selection = text
                    searchFocuse = false
                }
        }

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

        private var textInput: some View {
            ZStack(alignment: .trailing) {
                if isSearchable {
                    TextField(selection.isEmpty ? placeholder ?? "" : selection, text: $text)
                        .focused($searchFocuse)
                        .huiTypography(.p1)
                        .foregroundColor(textInputTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(HorizonUI.spaces.space12)
                        .padding(.trailing, .huiSpaces.space24)
                        .overlay(textOverlay(isOuter: false))
                        .onChange(of: searchFocuse, onFocusChange)
                        .onChange(of: text, onTextChange)
                        .onChange(of: selection) { _, newValue in text = newValue }
                        .onChange(of: focused) { _, newValue in searchFocuse = newValue }
                } else {
                    Text(selection.isEmpty ? placeholder ?? "" : selection)
                        .huiTypography(.p1)
                        .foregroundColor(textInputTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(HorizonUI.spaces.space12)
                        .padding(.trailing, .huiSpaces.space24)
                        .overlay(textOverlay(isOuter: false))
                }
                Image.huiIcons.chevronRight
                    .padding(.horizontal, .huiSpaces.space12)
                    .tint(Color.huiColors.icon.default)
                    .rotationEffect(.degrees(focused ? -90 : 90))
                    .animation(.easeInOut, value: focused)
            }
            .padding(.huiSpaces.space4)
            .overlay(textOverlay(isOuter: true))
            .frame(maxWidth: .infinity)
            .background {
                GeometryReader { geometry in
                    HStack {}
                        .onAppear {
                            textInputMeasuredHeight = geometry.size.height
                        }
                }
            }
            .onTapGesture(perform: onTapText)
            .background(Color.huiColors.surface.cardPrimary)
            .opacity(disabled ? 0.5 : 1.0)
        }

        // MARK: - Private Functions

        private func onTapText() {
            if disabled {
                return
            }
            focused = !focused
        }

        private var textInputTextColor: Color {
            selection.isEmpty ? .huiColors.text.placeholder : .huiColors.text.body
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

        private func onFocusChange(oldValue: Bool, newValue: Bool) {
            focused = newValue
            if newValue {
                filteredItems = options
            } else {
                let firstMatch = options.first { $0.lowercased() == text.lowercased() }
                if firstMatch == nil {
                    selection = originalSelection
                    text = originalSelection
                }
            }
        }

        private func onTextChange(oldValue: String, newValue: String) {
            if !focused {
                return
            }

            // If the text input is empty, display all items
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                filteredItems = options
                return
            }

            // Display only the items that match what the user's input
            filteredItems = options.filter { $0.lowercased().contains(text.lowercased()) }

            // If what they've typed leaves no filtered items, display all options

            if filteredItems.isEmpty {
                filteredItems = options
            }
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
    @Previewable @State var selection = ""
    @Previewable @State var focused = false

    @Previewable @State var selectedOptionIndex = 0

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

    VStack {
        HorizonUI.SingleSelect(
            selection: $selection,
            focused: $focused,
            label: "Words of the Alphabet",
            options: options,
            disabled: false,
            placeholder: "Select an option",
            error: "This is an error"
        )

        HorizonUI.PrimaryButton("Save Changes", type: .black, fillsWidth: true) {}
    }
    .padding(.horizontal, .huiSpaces.space24)
}
