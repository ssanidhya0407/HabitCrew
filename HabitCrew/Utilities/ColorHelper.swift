//
//  ColorHelper.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class ColorHelper {
    static func color(fromHex hexString: String?) -> UIColor {
        // Default color if nil or invalid hex
        guard let hexString = hexString else {
            return .systemBlue
        }
        
        // Try to use the existing UIColor(hex:) if available, otherwise provide a fallback
        if let color = tryCreateColor(fromHex: hexString) {
            return color
        } else {
            return .systemBlue
        }
    }
    
    private static func tryCreateColor(fromHex hexString: String) -> UIColor? {
        // Try to use the existing initializer, which might be defined differently
        // If it fails, return nil
        return UIColor(hex: hexString)
    }
}