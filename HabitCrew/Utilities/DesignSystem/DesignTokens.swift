import UIKit

struct DesignTokens {

    struct Pastel {
        static let blue = UIColor(hex: "#A7D1FF") ?? .blue
        static let green = UIColor(hex: "#B7F2B3") ?? .green
        static let yellow = UIColor(hex: "#FFF5BA") ?? .yellow
        static let pink = UIColor(hex: "#FFBBD9") ?? .systemPink
        static let purple = UIColor(hex: "#D1B3FF") ?? .purple
    }

    struct Background {
        static let primary = UIColor(hex: "#F7F9FB") ?? .systemBackground // Light background
        static let secondary = UIColor(hex: "#FFFFFF") ?? .secondarySystemBackground // White card background
        static let elevated = UIColor(hex: "#FFFFFF") ?? .tertiarySystemBackground // White elevated background
    }

    struct Accent {
        static let mint = UIColor(hex: "#B7F2B3") ?? .green // Pastel Green
        static let purple = UIColor(hex: "#D1B3FF") ?? .purple // Pastel Purple
        static let coral = UIColor(hex: "#FFBBD9") ?? .systemPink // Pastel Pink
        static let green = UIColor(hex: "#B7F2B3") ?? .green // Pastel Green
        static let orange = UIColor(hex: "#FFF5BA") ?? .orange // Pastel Yellow
    }

    struct Text {
        static let primary = UIColor.black // Dark text
        static let secondary = UIColor(hex: "#6B7280") ?? .secondaryLabel // Gray text
        static let tertiary = UIColor(hex: "#9CA3AF") ?? .tertiaryLabel
        static let disabled = UIColor(hex: "#D1D5DB") ?? .quaternaryLabel
    }

    struct Semantic {
        static let buttonPrimary = UIColor(hex: "#A7D1FF") ?? .systemBlue // Pastel Blue
        static let buttonSecondary = UIColor(hex: "#FFFFFF") ?? .secondarySystemFill // White
        static let buttonDestructive = UIColor(hex: "#FFBBD9") ?? .systemRed // Pastel Pink
        static let border = UIColor(hex: "#E5E7EB") ?? .separator
        static let divider = UIColor(hex: "#E5E7EB") ?? .opaqueSeparator
    }

    struct System {
        static let success = UIColor(hex: "#30D158") ?? .systemGreen
        static let warning = UIColor(hex: "#FF9F0A") ?? .systemOrange
        static let error = UIColor(hex: "#FF3B30") ?? .systemRed
        static let info = UIColor(hex: "#007AFF") ?? .systemBlue
    }

    struct Spacing {
        static let small: CGFloat = 8.0
        static let medium: CGFloat = 16.0
        static let large: CGFloat = 24.0
    }

    struct BorderRadius {
        static let small: CGFloat = 4.0
        static let medium: CGFloat = 8.0
        static let large: CGFloat = 12.0
    }

    struct Font {
        static let headline: UIFont = .systemFont(ofSize: 24, weight: .bold) // SF Pro Bold
        static let title: UIFont = .systemFont(ofSize: 20, weight: .semibold) // SF Pro Semibold
        static let body: UIFont = .systemFont(ofSize: 16, weight: .regular) // SF Pro Regular
        static let caption: UIFont = .systemFont(ofSize: 12, weight: .medium) // SF Pro Medium
    }
    
    struct Gradients {
        static let mintPurple = [UIColor(hex: "#B7F2B3")?.cgColor ?? UIColor.green.cgColor, UIColor(hex: "#D1B3FF")?.cgColor ?? UIColor.purple.cgColor]
        static let purpleCoral = [UIColor(hex: "#D1B3FF")?.cgColor ?? UIColor.purple.cgColor, UIColor(hex: "#FFBBD9")?.cgColor ?? UIColor.systemPink.cgColor]
        static let success = [UIColor(hex: "#30D158")?.cgColor ?? UIColor.systemGreen.cgColor, UIColor(hex: "#B7F2B3")?.cgColor ?? UIColor.green.cgColor]
    }
}
