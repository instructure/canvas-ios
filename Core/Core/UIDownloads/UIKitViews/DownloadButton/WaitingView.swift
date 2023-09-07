import UIKit
@available(iOS 13.0, *)
class WaitingView: UIView {

    // MARK: - Properties -

    var rotationStartingAngle  = CGFloat.pi
    var rotationEndingAngle = 3 * CGFloat.pi/2
    var shouldSpin = true
    var isClockwise = false
    var strokeWidth: CGFloat = 2

    var strokeColor = UIColor.systemBlue {
        didSet {
            circleLayer.strokeColor = strokeColor.cgColor
        }
    }

    var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        return layer
    }()

    // MARK: - Initializers -

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        circleLayer.strokeColor = strokeColor.cgColor
        circleLayer.lineWidth  = strokeWidth
        layer.addSublayer(circleLayer)
    }

    override func didMoveToWindow() {
        if shouldSpin { startSpinning() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius = min(frame.width / 2, frame.height / 2) - strokeWidth / 2
        circleLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: rotationStartingAngle, endAngle: rotationEndingAngle, clockwise: isClockwise).cgPath
    }

    func startSpinning() {
        let animationKey = "rotation"
        layer.removeAnimation(forKey: animationKey)
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 2
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        layer.add(rotationAnimation, forKey: animationKey)
    }

}
