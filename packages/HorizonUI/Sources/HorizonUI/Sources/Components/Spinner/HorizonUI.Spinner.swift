import SwiftUI

extension HorizonUI {
    struct Spinner: View {
        // MARK: - Dependencies

        private let showBackground: Bool
        private let size: SpinnerSize

        // MARK: - Private

        private let backgroundColor = Color(red: 232/255, green: 234/255, blue: 236/255)
        private let foregroundColor = Color(red: 9/255, green: 80/255, blue: 140/255)

        // MARK: - Init

        init(size: SpinnerSize = .medium, showBackground: Bool = false) {
            self.size = size
            self.showBackground = showBackground
        }

        var body: some View {
            ZStack {
                if showBackground {
                    SpinnerCircle(
                        color: backgroundColor,
                        diameter: size.dimension,
                        isFullCircle: true,
                        strokeWidth: size.strokeWidth
                    )
                }
                SpinnerCircle(
                    color: foregroundColor,
                    diameter: size.dimension,
                    isFullCircle: false,
                    strokeWidth: size.strokeWidth
                )
            }
            .frame(
                width: size.dimension + size.strokeWidth,
                height: size.dimension + size.strokeWidth
            )
        }
    }
}

fileprivate struct SpinnerCircle: View {

    // MARK: - Dependencies

    let color: Color
    let diameter: CGFloat
    let isFullCircle: Bool
    let strokeWidth: CGFloat

    // MARK: - Private

    @State private var rotation: Double = 0

    var body: some View {
        PartialCircleShape(diameter: diameter, isFullCircle: isFullCircle)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: strokeWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

fileprivate struct PartialCircleShape: Shape {
    let diameter: CGFloat
    let isFullCircle: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = diameter / 2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(isFullCircle ? 360 : 270),
            clockwise: false
        )

        return path
    }
}

#Preview {
    HorizonUI.Spinner(showBackground: true)
}
