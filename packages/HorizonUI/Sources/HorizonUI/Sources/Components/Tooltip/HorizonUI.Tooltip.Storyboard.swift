import SwiftUI
import TipKit

struct TooltipStoryboard: View {
    @State private var isDarkTooltipVisible = false
    @State private var isLightTooltipVisible = false

    var body: some View {
        ZStack {
            // Background tap handler to close tooltips
            if isDarkTooltipVisible || isLightTooltipVisible {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            isDarkTooltipVisible = false
                            isLightTooltipVisible = false
                        }
                    }
                    .ignoresSafeArea()
            }

            VStack(spacing: 32) {
                // Dark Tooltip Example
                Button("Toggle Dark Tooltip") {
                    withAnimation {
                        isDarkTooltipVisible.toggle()
                        isLightTooltipVisible = false
                    }
                }
                .overlay(alignment: .trailing) {
                    HorizonUI.Tooltip(
                        text: "This is a dark tooltip",
                        style: .dark,
                        isVisible: $isDarkTooltipVisible
                    )
                    .offset(x: 8)
                }

                // Light Tooltip Example
                Button("Toggle Light Tooltip") {
                    withAnimation {
                        isLightTooltipVisible.toggle()
                        isDarkTooltipVisible = false
                    }
                }
                .overlay(alignment: .leading) {
                    HorizonUI.Tooltip(
                        text: "This is a light tooltip",
                        style: .light,
                        isVisible: $isLightTooltipVisible
                    )
                    .offset(x: -8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    TooltipStoryboard()
}
