import SwiftUI
import UIKit

final class ConfettiContainerView: UIView {
    private var emitterLayer: CAEmitterLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer?.emitterPosition = CGPoint(x: bounds.midX, y: -8)
        emitterLayer?.emitterSize = CGSize(width: bounds.width, height: 1)
    }

    func startConfetti() {
        stopConfetti()

        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterMode = .outline
        emitter.renderMode = .unordered
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -8)
        emitter.emitterSize = CGSize(width: max(bounds.width, 1), height: 1)

        let colors: [UIColor] = [
            UIColor(red: 0.95, green: 0.35, blue: 0.55, alpha: 1),
            .systemYellow,
            .systemGreen,
            .systemBlue,
            .systemOrange,
            .white,
            .systemPurple
        ]

        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 5
            cell.lifetime = 7
            cell.lifetimeRange = 2
            cell.velocity = 140
            cell.velocityRange = 70
            cell.yAcceleration = 180
            cell.xAcceleration = 8
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 3
            cell.spin = 3.5
            cell.spinRange = 4
            cell.scale = 0.11
            cell.scaleRange = 0.06
            cell.contents = Self.paperImage(color: color).cgImage
            return cell
        }

        layer.addSublayer(emitter)
        emitterLayer = emitter

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak emitter] in
            emitter?.birthRate = 0
        }
    }

    func stopConfetti() {
        emitterLayer?.removeFromSuperlayer()
        emitterLayer = nil
    }

    private static func paperImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 18, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            color.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 3).fill()
            UIColor.white.withAlphaComponent(0.25).setFill()
            UIBezierPath(rect: CGRect(x: 3, y: 3, width: 5, height: 16)).fill()
        }
    }
}

struct ConfettiView: UIViewRepresentable {
    var isActive: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ConfettiContainerView {
        let view = ConfettiContainerView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: ConfettiContainerView, context: Context) {
        if isActive, !context.coordinator.isActive {
            context.coordinator.isActive = true
            uiView.startConfetti()
        } else if !isActive, context.coordinator.isActive {
            context.coordinator.isActive = false
            uiView.stopConfetti()
        }
    }

    final class Coordinator {
        var isActive = false
    }
}
