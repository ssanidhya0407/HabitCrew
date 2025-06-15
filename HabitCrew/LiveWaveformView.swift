//
//  LiveWaveformView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 15/06/25.
//


import UIKit

class LiveWaveformView: UIView {
    private var bars: [UIView] = []
    private var barHeights: [NSLayoutConstraint] = []
    private let barCount = 18
    private let minBarHeight: CGFloat = 6
    private let maxBarHeight: CGFloat = 26

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = .clear
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        for _ in 0..<barCount {
            let bar = UIView()
            bar.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            bar.layer.cornerRadius = 2.5
            bar.translatesAutoresizingMaskIntoConstraints = false
            let height = NSLayoutConstraint(
                item: bar, attribute: .height,
                relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                multiplier: 1, constant: minBarHeight
            )
            bar.addConstraint(height)
            stack.addArrangedSubview(bar)
            bars.append(bar)
            barHeights.append(height)
        }
    }

    func update(with level: Float) {
        let clampedLevel = max(0, min(1, level))
        for (i, constraint) in barHeights.enumerated() {
            let phase = CGFloat(i) / CGFloat(barCount) * .pi * 2
            let normalized = CGFloat(clampedLevel) * 0.8 + 0.2
            let targetHeight = minBarHeight + (maxBarHeight - minBarHeight) * (sin(phase + CGFloat(Date().timeIntervalSinceReferenceDate * 4)) * 0.35 + 0.65) * normalized
            UIView.animate(withDuration: 0.09, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                constraint.constant = targetHeight
                self.bars[i].layoutIfNeeded()
            }, completion: nil)
        }
    }
    func reset() {
        for constraint in barHeights {
            constraint.constant = minBarHeight
        }
        setNeedsLayout()
    }
}