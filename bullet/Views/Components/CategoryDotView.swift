//
//  CategoryDotView.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI

struct CategoryDotView: View {
    let color: Color
    let size: CGFloat

    init(color: Color, size: CGFloat = DesignSystem.IconSize.small) {
        self.color = color
        self.size = size
    }

    var body: some View {
        Image(systemName: "circle.fill")
            .foregroundColor(color)
            .tint(color)
            .font(.system(size: size))
    }
}

// MARK: - Convenience Initializers
extension CategoryDotView {
    init(category: CategoryItem?, size: CGFloat = DesignSystem.IconSize.small) {
        self.init(color: category?.color ?? .secondary, size: size)
    }
}
