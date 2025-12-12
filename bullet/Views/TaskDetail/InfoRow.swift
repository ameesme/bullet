//
//  InfoRow.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI

struct InfoRow: View {
    let title: String
    var value: String?
    var valueView: AnyView?

    init(title: String, value: String) {
        self.title = title
        self.value = value
        self.valueView = nil
    }

    init(title: String, valueView: AnyView) {
        self.title = title
        self.valueView = valueView
        self.value = nil
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let valueView {
                valueView
            } else if let value {
                Text(value)
            }
        }
        .font(.body)
        .foregroundStyle(.secondary)
        .frame(minHeight: DesignSystem.Layout.minRowHeight)
    }
}
