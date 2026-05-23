//
//  HexColor.swift
//  TakeHomeExerciseProject
//
//  Created by Mohd Naqvi on 22/05/26.
//

import SwiftUI

extension Color {
    init(hex: String, fallback: Color = .primary) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard sanitized.count == 6, let rgb = UInt64(sanitized, radix: 16) else {
            self = fallback
            return
        }

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

extension Theme {
    var background: Color { Color(hex: backgroundColor, fallback: .white) }
    var text: Color { Color(hex: textColor, fallback: .primary) }
    var clickableText: Color { Color(hex: clickableTextColor, fallback: .blue) }
    var border: Color { Color(hex: borderColor, fallback: .gray) }
    var error: Color { Color(hex: errorColor, fallback: .red) }
    var button: Color { Color(hex: buttonColor, fallback: .accentColor) }
}
