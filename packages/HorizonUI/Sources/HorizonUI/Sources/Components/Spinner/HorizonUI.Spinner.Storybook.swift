import SwiftUI

extension HorizonUI.Spinner {
    struct Storybook: View {
        public var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        HorizonUI.Spinner(size: .xSmall)
                        HorizonUI.Spinner(size: .small)
                        HorizonUI.Spinner(size: .medium)
                        HorizonUI.Spinner(size: .large)
                    }
                    HStack(spacing: 10) {
                        HorizonUI.Spinner(size: .xSmall, showBackground: true)
                        HorizonUI.Spinner(size: .small, showBackground: true)
                        HorizonUI.Spinner(size: .medium, showBackground: true)
                        HorizonUI.Spinner(size: .large, showBackground: true)
                    }
                }
            }
            .navigationTitle("Spinners")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HorizonUI.Spinner.Storybook()
}
