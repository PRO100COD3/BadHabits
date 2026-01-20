//
//  Button+PressAnimation.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 19.01.2026.
//

import SwiftUI

struct PressAnimationButtonStyle: ButtonStyle {
    private let pressScale: CGFloat = 0.96
    private let pressOpacity: Double = 0.9
    private let pressDuration: Double = 0.150
    private let releaseDuration: Double = 0.1
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressScale : 1.0)
            .opacity(configuration.isPressed ? pressOpacity : 1.0)
            .animation(
                .easeInOut(
                    duration: configuration.isPressed ? pressDuration : releaseDuration
                ),
                value: configuration.isPressed
            )
    }
}

extension View {
    func pressAnimation() -> some View {
        self.buttonStyle(PressAnimationButtonStyle())
    }
}
