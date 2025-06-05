import UIKit

extension UIView {
    func applyGradient(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        // Remove existing gradient layers first
        self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds
        
        // Insert gradient at index 0 so it's below other subviews
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addShadow(opacity: Float, radius: CGFloat, offset: CGSize, color: UIColor = .black) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}
