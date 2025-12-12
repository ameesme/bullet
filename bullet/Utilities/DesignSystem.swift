//
//  DesignSystem.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI

enum DesignSystem {
    // MARK: - Spacing
    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let huge: CGFloat = 32
    }

    // MARK: - Layout
    enum Layout {
        static let listRowHeight: CGFloat = 48
        static let minRowHeight: CGFloat = 44
        static let emptyStateImageSize: CGFloat = 100
        static let maxEmptyStateWidth: CGFloat = 480
        static let safeAreaTopOffset: CGFloat = 16
    }

    // MARK: - Toggle Dimensions
    enum Toggle {
        static let height: CGFloat = 36
        static let width: CGFloat = 92
        static let padding: CGFloat = 3
        static let knobWidthExtra: CGFloat = 20
    }

    // MARK: - Icon Sizes
    enum IconSize {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }

    // MARK: - Animation
    enum Animation {
        static let springResponse: Double = 0.35
        static let springDamping: Double = 0.9
        static let springBlend: Double = 0.1
    }

    // MARK: - Gradient Stops
    enum Gradient {
        static let headerMaskStops: [SwiftUI.Gradient.Stop] = [
            .init(color: .black, location: 0.0),
            .init(color: .black, location: 0.9),
            .init(color: .black.opacity(0.0), location: 1.0)
        ]
    }
}
