import Foundation
import UIKit

class LoadingView: UIView {

    private let circleLayer = CAShapeLayer()
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(bounds.width, bounds.height) / 2 - 15,
            startAngle: 0,
            endAngle: CGFloat.pi * 1.5,
            clockwise: true
        )

        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor.red.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 8
        circleLayer.lineCap = .round

        layer.addSublayer(circleLayer)
    }

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        animateLoadingCircle()
    }

    func stopAnimating() {
        isAnimating = false
        circleLayer.removeAllAnimations()
    }

    private func animateLoadingCircle() {
        guard isAnimating else { return }

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = .infinity

        layer.add(rotationAnimation, forKey: "rotateAnimation")
    }
}
