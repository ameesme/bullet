//
//  HeaderView.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    @Binding var isShowingDead: Bool

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.largeTitle).bold()

            Spacer()

            LivingDeadToggle(isOn: $isShowingDead)
                .accessibilityLabel("\(title) toggle")
        }
    }
}
