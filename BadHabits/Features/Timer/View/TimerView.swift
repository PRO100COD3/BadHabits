//
//  TimerView.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 19.01.2026.
//

import SwiftUI

struct TimerView: View {
    let initialText: String
    
    @StateObject private var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(initialText: String = "") {
        self.initialText = initialText
        _viewModel = StateObject(wrappedValue: TimerViewModel(initialText: initialText))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("backgroundTimer")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.showCloseDialog()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.18))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 44, height: 44)
                        .padding(.top, 3)
                        .padding(.trailing, 14)
                        .pressAnimation()
                    }
                    
                    TextField("", text: $viewModel.text)
                        .font(.custom("Onest", size: 24))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(.top, 46)
                        .padding(.horizontal, 20)
                        .onChange(of: viewModel.text) { newValue in
                            viewModel.handleTextChange(newValue)
                        }
                                        
                    CircularProgressView(
                        progress: viewModel.progress,
                        days: viewModel.days,
                        timeString: viewModel.timeString
                    )
                    .padding(.top, 53)
                    
                    Button(action: {
                        if viewModel.shouldShowRestart {
                            viewModel.showRestartDialog()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        Text(viewModel.shouldShowRestart ? "РЕСТАРТ" : "СТАРТ")
                            .font(.custom("Onest", size: 20))
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 1, green: 1, blue: 1))
                                    .opacity(0.3)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.8), lineWidth: 1)
                                    }
                                    .frame(width: 115, height: 37)
                                    
                            }
                    }
                    .frame(width: 115, height: 37)
                    .padding(.top, 68)
                    .pressAnimation()
                    
                    HStack(spacing: 80) {
                        Button(action: {
                            // Действие для первой кнопки
                        }) {
                            Image("book")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .pressAnimation()
                        
                        Button(action: {
                            // Действие для второй кнопки
                        }) {
                            Image("time")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                
                        }
                        .pressAnimation()
                        
                        Button(action: {
                            // Действие для третьей кнопки
                        }) {
                            Image("trash")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .pressAnimation()
                    }
                    .padding(.top, 57)
                    .padding([.leading, .trailing], 67)
                    
                    Spacer()
                }
            }
            .blur(radius: viewModel.shouldShowRestartDialog || viewModel.shouldShowCloseDialog ? 8 : 0)
            .overlay {
                if viewModel.shouldShowRestartDialog || viewModel.shouldShowCloseDialog {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.225), value: viewModel.shouldShowRestartDialog || viewModel.shouldShowCloseDialog)
                }
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        hideKeyboard()
                    }
            )
            .overlay(alignment: .top) {
                if viewModel.showLimitAlert {
                    CharacterLimitAlert(maxLength: viewModel.maxLength, isPresented: $viewModel.showLimitAlert)
                        .padding(24)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showLimitAlert)
            .overlay(alignment: .top) {
                if viewModel.showRestartReasonLimitAlert {
                    CharacterLimitAlert(maxLength: viewModel.restartReasonMaxLength, isPresented: $viewModel.showRestartReasonLimitAlert)
                        .padding(24)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showRestartReasonLimitAlert)
            .overlay(alignment: .top) {
                RestartDialog(
                    isPresented: $viewModel.shouldShowRestartDialog,
                    reason: $viewModel.restartReason,
                    characterLimit: viewModel.restartReasonMaxLength,
                    onConfirm: {
                        viewModel.confirmRestart()
                    },
                    onCancel: {
                        viewModel.cancelRestart()
                    },
                    onCharacterLimitExceeded: {
                        viewModel.showRestartReasonCharacterLimitAlert()
                    }
                )
                .padding(.top, 238)
            }
            .overlay(alignment: .top) {
                ConfirmationDialog(
                    isPresented: $viewModel.shouldShowCloseDialog,
                    onConfirm: {
                        viewModel.confirmClose()
                        dismiss()
                    },
                    onCancel: {
                        viewModel.cancelClose()
                    }
                )
                .padding(.top, 270)
            }
        }
    }
}

#Preview {
    TimerView(initialText: "")
}
