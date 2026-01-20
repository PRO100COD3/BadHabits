//
//  CharacterLimitAlert.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 19.01.2026.
//

import SwiftUI

struct CharacterLimitAlert: View {
    let maxLength: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        if isPresented {
            HStack(spacing: 12) {
                Text("Максимальное кол-во символов - \(maxLength)")
                    .font(.custom("Onest", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .padding(24)
            .frame(height: 58)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.612, blue: 0.612),
                                Color(red: 0.906, green: 0.329, blue: 0.329)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
    }
}
