//
//  ConfirmationDialog.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 21.01.2026.
//

import SwiftUI

struct ConfirmationDialog: View {
    @Binding var isPresented: Bool
    
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        if isPresented {
            VStack(spacing: 12) {
                HStack {
                    Text("Подтвердите удаление")
                        .font(.custom("Onest", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#222222"))
                    
                    Spacer()
                }
                
                HStack {
                    Text("Вы уверены, что хотите \nудалить эту карточку?")
                        .font(.custom("Onest", size: 16))
                        .fontWeight(.regular)
                        .foregroundColor(Color(hex: "#555555"))
                        .lineLimit(2)
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            onCancel()
                        }
                    }) {
                        Text("ОТМЕНА")
                            .font(.custom("Onest", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#6E6E6E"))
                            .frame(maxWidth: .infinity, maxHeight: 36)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(hex: "#CCCCCCCC"), lineWidth: 1)
                                    }
                            }
                    }
                    .pressAnimation()
                    .padding(.top, 12)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            onConfirm()
                        }
                    }) {
                        Text("УДАЛИТЬ")
                            .font(.custom("Onest", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#F4F4F4"))
                            .frame(maxWidth: .infinity, maxHeight: 36)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.redButton)
                                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(hex: "#D0D0D0E5"), lineWidth: 1)
                                    }
                            }
                    }
                    .pressAnimation()
                    .padding(.top, 12)
                }
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.984, green: 0.984, blue: 0.984),
                                Color(red: 0.922, green: 0.922, blue: 0.922)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 4)
            }
            .padding(.horizontal, 37)
            .opacity(isPresented ? 1.0 : 0.0)
            .scaleEffect(isPresented ? 1.0 : 0.95)
        }
    }
}
