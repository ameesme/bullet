//
//  LivingDeadToggle.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI

struct LivingDeadToggle: View {
    @Binding var isOn: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let height = DesignSystem.Toggle.height
    private let width = DesignSystem.Toggle.width
    private let padding = DesignSystem.Toggle.padding

    var body: some View {
        let knobHeight = height - padding * 2
        let knobWidth = knobHeight + DesignSystem.Toggle.knobWidthExtra
        let corner = knobHeight / 2
        let foreground = Color(.label)
        let background = Color(.systemBackground)

        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()

            withAnimation(reduceMotion ? nil : .spring(
                response: DesignSystem.Animation.springResponse,
                dampingFraction: DesignSystem.Animation.springDamping,
                blendDuration: DesignSystem.Animation.springBlend
            )) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(isOn ? foreground : background)
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                            .stroke(foreground, lineWidth: 2)
                    )

                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(isOn ? background : foreground)
                    .frame(width: knobWidth, height: knobHeight)
                    .padding(padding)
            }
            .frame(width: width, height: height)
            .contentShape(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isOn ? "Dead" : "Living")
    }
}
