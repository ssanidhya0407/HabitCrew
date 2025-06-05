//
//  ConfettiView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class ConfettiView: UIView {
    
    private var emitter: CAEmitterLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: frame.width / 2, y: -50)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: frame.width, height: 1)
        emitter.renderMode = .additive
        
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPurple, .systemOrange
        ]
        
        var cells: [CAEmitterCell] = []
        for color in colors {
            cells.append(confettiCell(with: color))
        }
        
        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        
        // Initially hidden
        emitter.birthRate = 0
    }
    
    private func confettiCell(with color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 6
        cell.lifetime = 10
        cell.velocity = 150
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.spin = 3
        cell.spinRange = 3
        cell.scale = 0.5
        cell.scaleRange = 0.3
        cell.color = color.cgColor
        cell.contents = confettiImage(with: color).cgImage
        cell.alphaSpeed = -0.1
        return cell
    }
    
    private func confettiImage(with color: UIColor) -> UIImage {
        let size = CGSize(width: 12, height: 12)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            // Random shape type
            let shapeType = Int.random(in: 0...2)
            
            ctx.cgContext.setFillColor(color.cgColor)
            
            switch shapeType {
            case 0: // Circle
                ctx.cgContext.addEllipse(in: CGRect(origin: .zero, size: size))
                ctx.cgContext.fillPath()
                
            case 1: // Rectangle
                ctx.cgContext.fill(CGRect(origin: .zero, size: size))
                
            case 2: // Triangle
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width/2, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.close()
                
                UIColor(cgColor: color.cgColor).setFill()
                path.fill()
                
            default:
                break
            }
        }
    }
    
    func startConfetti() {
        emitter.birthRate = 1
    }
    
    func stopConfetti() {
        emitter.birthRate = 0
    }
}