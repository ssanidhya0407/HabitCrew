import UIKit

// MARK: - Icon Picker Sheet
class IconPickerSheet: UIViewController {
    var icons: [String] = []
    var selectedIcon: String?
    var onSelect: ((String) -> Void)?

    private let columns = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear // Allow background to show through

        // Blurred background for sheet
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.layer.cornerRadius = 22
        blur.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blur.layer.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
        container.layer.cornerRadius = 22
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 14
        grid.alignment = .fill
        grid.translatesAutoresizingMaskIntoConstraints = false

        let rows = Int(ceil(Double(icons.count) / Double(columns)))
        for row in 0..<rows {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.spacing = 14
            hStack.alignment = .fill
            hStack.distribution = .fillEqually

            for col in 0..<columns {
                let idx = row * columns + col
                if idx < icons.count {
                    let iconName = icons[idx]
                    let btn = UIButton(type: .system)
                    btn.setImage(UIImage(systemName: iconName), for: .normal)
                    btn.tintColor = (iconName == selectedIcon) ? .systemBlue : .label
                    btn.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(iconName == selectedIcon ? 0.8 : 0.5)
                    btn.layer.cornerRadius = 14
                    btn.layer.borderWidth = iconName == selectedIcon ? 2 : 0
                    btn.layer.borderColor = UIColor.systemBlue.cgColor
                    btn.tag = idx
                    btn.addTarget(self, action: #selector(iconTapped(_:)), for: .touchUpInside)
                    btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    hStack.addArrangedSubview(btn)
                } else {
                    let spacer = UIView()
                    hStack.addArrangedSubview(spacer)
                }
            }
            grid.addArrangedSubview(hStack)
        }

        container.addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            grid.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            grid.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            grid.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])

        // Layout: container overlays blurView
        blur.contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor)
        ])

        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            blur.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    @objc private func iconTapped(_ sender: UIButton) {
        let idx = sender.tag
        let iconName = icons[idx]
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        onSelect?(iconName)
        dismiss(animated: true)
    }
}

// MARK: - Color Picker Sheet
// MARK: - Color Picker Sheet
class ColorPickerSheet: UIViewController {
    var colors: [UIColor] = []
    var selectedColor: UIColor?
    var onSelect: ((UIColor) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // Blurred, rounded "sheet"
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.layer.cornerRadius = 22
        blur.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blur.layer.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
        container.layer.cornerRadius = 22
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false

        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 20
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        for color in colors {
            let btn = UIButton(type: .system)
            btn.backgroundColor = color
            btn.layer.cornerRadius = 22
            btn.layer.borderWidth = (color == selectedColor) ? 3 : 0
            btn.layer.borderColor = UIColor.label.withAlphaComponent(0.22).cgColor
            btn.widthAnchor.constraint(equalToConstant: 44).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
            btn.tag = colors.firstIndex(of: color) ?? 0
            btn.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)

            if color == selectedColor {
                let check = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
                check.tintColor = .white
                check.translatesAutoresizingMaskIntoConstraints = false
                btn.addSubview(check)
                NSLayoutConstraint.activate([
                    check.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -2),
                    check.bottomAnchor.constraint(equalTo: btn.bottomAnchor, constant: -2),
                    check.widthAnchor.constraint(equalToConstant: 20),
                    check.heightAnchor.constraint(equalToConstant: 20)
                ])
            }
            hStack.addArrangedSubview(btn)
        }
        scroll.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: scroll.topAnchor),
            hStack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -12),
            hStack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            hStack.heightAnchor.constraint(equalToConstant: 54)
        ])

        container.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            scroll.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        blur.contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor)
        ])

        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Height at least 100–140 to show the row!
            blur.heightAnchor.constraint(equalToConstant: 110),
            blur.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    @objc private func colorTapped(_ sender: UIButton) {
        let color = colors[sender.tag]
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        onSelect?(color)
        dismiss(animated: true)
    }
}
