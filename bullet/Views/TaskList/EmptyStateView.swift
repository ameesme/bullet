//
//  EmptyStateView.swift
//  bullet
//
//  Created by Mees on 12/12/2025.
//

import SwiftUI

struct EmptyStateView: View {
    let isShowingDead: Bool
    let hasCategoryFilter: Bool
    let clearFiltersAction: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            if isShowingDead {
                Image(isShowingDead ? "cemetary.empty" : "cemetary")
                    .resizable()
                    .frame(
                        width: DesignSystem.Layout.emptyStateImageSize,
                        height: DesignSystem.Layout.emptyStateImageSize
                    )
                    .aspectRatio(contentMode: .fit)
                    .colorInvert()
            } else {
                Image(isShowingDead ? "cemetary.empty" : "cemetary")
                    .resizable()
                    .frame(
                        width: DesignSystem.Layout.emptyStateImageSize,
                        height: DesignSystem.Layout.emptyStateImageSize
                    )
                    .aspectRatio(contentMode: .fit)
            }

            VStack(spacing: DesignSystem.Spacing.medium) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: DesignSystem.Spacing.medium + DesignSystem.Spacing.small) {
                if hasCategoryFilter {
                    Button {
                        clearFiltersAction()
                    } label: {
                        Label("Clear filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.huge)
        .frame(maxWidth: DesignSystem.Layout.maxEmptyStateWidth)
        .accessibilityElement(children: .contain)
    }

    private var title: String {
        if hasCategoryFilter {
            return "Nothing found for these categories."
        } else {
            return isShowingDead ? "Nothing's dead (yet)" : "Everything's dead"
        }
    }

    private var message: String {
        if hasCategoryFilter {
            return ""
        }

        return isShowingDead ? "Why?" : "You killed it."
    }
}
