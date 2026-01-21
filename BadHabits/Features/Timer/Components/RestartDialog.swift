//
//  RestartDialog.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 19.01.2026.
//

import SwiftUI

struct RestartDialog: View {
    @Binding var isPresented: Bool
    @Binding var reason: String
    
    let characterLimit: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let onCharacterLimitExceeded: () -> Void
    
    @State private var textEditorHeight: CGFloat = 48
    @State private var wasOverLimit: Bool = false
    @State private var containerWidth: CGFloat = 0
    
    private var font: UIFont {
        let descriptor = UIFontDescriptor(name: "Onest", size: 14)
            .addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium]])
        return UIFont(descriptor: descriptor, size: 14)
    }
    private let minHeight: CGFloat = 48
    private let maxHeight: CGFloat = 66
    
    private var isOverLimit: Bool {
        reason.count > characterLimit
    }
    
    var body: some View {
        if isPresented {
            VStack {
                HStack(spacing: 12) {
                    Text("Рестарт")
                        .font(.custom("Onest", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#222222"))
                    
                    Spacer()
                }
                
                ZStack(alignment: .topLeading) {
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#F7F7F7"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isOverLimit ? Color(hex: "#E75454") : Color(hex: "#E6E6E6"), lineWidth: 1)
                            }
                            .onAppear {
                                containerWidth = geometry.size.width
                                calculateHeight(for: reason)
                            }
                            .onChange(of: geometry.size.width) { newWidth in
                                containerWidth = newWidth
                                calculateHeight(for: reason)
                            }
                    }
                    
                    TextEditor(text: $reason)
                        .font(.custom("Onest", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#9CA3AF"))
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 7)
                        .padding(.trailing, 5)
                    
                    if reason.isEmpty {
                        Text("Причина")
                            .font(.custom("Onest", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#9CA3AF"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 15)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: textEditorHeight)
                .onChange(of: reason) { newValue in
                    let maxCharacters = characterLimit + 1
                    if newValue.count > maxCharacters {
                        reason = String(newValue.prefix(maxCharacters))
                        return
                    }
                    
                    calculateHeight(for: newValue)
                    
                    let currentlyOverLimit = newValue.count > characterLimit
                    if currentlyOverLimit && !wasOverLimit {
                        onCharacterLimitExceeded()
                    }
                    wasOverLimit = currentlyOverLimit
                }
                .onAppear {
                    wasOverLimit = reason.count > characterLimit
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            onCancel()
                        }
                    }) {
                        Text("ОТМЕНА")
                            .font(.custom("Onest", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#6E6E6E"))
                            .frame(maxWidth: .infinity, maxHeight: 36)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
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
                        Text("РЕСТАРТ")
                            .font(.custom("Onest", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 36)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.redButton)
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
            }
            .padding(.horizontal, 37)
            .opacity(isPresented ? 1.0 : 0.0)
            .scaleEffect(isPresented ? 1.0 : 0.95)
        }
    }
    
    private func calculateHeight(for text: String) {
        guard containerWidth > 0 else { return }
        
        let textWidth = containerWidth - 19 - 14
        
        let textToMeasure = text.isEmpty ? " " : text
        let attributedString = NSAttributedString(
            string: textToMeasure,
            attributes: [.font: font]
        )
        
        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        let calculatedHeight = ceil(boundingRect.height) + 14 + 17
        
        withAnimation(.easeInOut(duration: 0.15)) {
            textEditorHeight = min(max(calculatedHeight, minHeight), maxHeight)
        }
    }
}
