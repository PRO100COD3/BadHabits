//
//  Timer.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 19.01.2026.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

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

struct CircularProgressView: View {
    let progress: Double
    let days: Int
    let timeString: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 14)
                .frame(width: 280, height: 280)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)
            
            VStack(spacing: 8) {
                Text("\(days)")
                    .font(.custom("Onest", size: 50))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("дней")
                    .font(.custom("Onest", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(timeString)
                    .font(.custom("Onest", size: 24))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        }
    }
}

struct Timer: View {
    @State private var text: String = ""
    @State private var showLimitAlert = false
    @State private var isRunning = false
    @State private var days = 0
    @State private var elapsedSeconds: TimeInterval = 0
    @State private var timer: Foundation.Timer?
    
    private let maxLength = 17
    private let targetSeconds: TimeInterval = 24 * 60 * 60
    
    private var progress: Double {
        min(elapsedSeconds / targetSeconds, 1.0)
    }
    
    private var timeString: String {
        let hours = Int(elapsedSeconds) / 3600
        let minutes = (Int(elapsedSeconds) % 3600) / 60
        let seconds = Int(elapsedSeconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
                        Button(action: action) {
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
                    }
                    
                    TextField("Введите название", text: $text)
                        .font(.custom("Onest", size: 24))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding(.top, 46)
                        .padding(.horizontal, 20)
                        .onChange(of: text) { oldValue, newValue in
                            if newValue.count > maxLength {
                                text = String(newValue.prefix(maxLength))
                                
                                if !showLimitAlert {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showLimitAlert = true
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            showLimitAlert = false
                                        }
                                    }
                                }
                            }
                        }
                                        
                    CircularProgressView(
                        progress: progress,
                        days: days,
                        timeString: timeString
                    )
                    .padding(.top, 53)
                    
                    Button(action: {
                        if isRunning {
                            restartTimer()
                        } else {
                            if !text.isEmpty {
                                startTimer()
                            }
                        }
                    }) {
                        Text(isRunning ? "РЕСТАРТ" : "СТАРТ")
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
                    .disabled(!isRunning && text.isEmpty)
                    .padding(.top, 68)
                    
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
                        
                        Button(action: {
                            // Действие для второй кнопки
                        }) {
                            Image("time")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                
                        }
                        
                        Button(action: {
                            // Действие для третьей кнопки
                        }) {
                            Image("trash")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .padding(.top, 57)
                    .padding([.leading, .trailing], 67)
                    
                    Spacer()
                }
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        hideKeyboard()
                    }
            )
            .overlay(alignment: .top) {
                if showLimitAlert {
                    CharacterLimitAlert(maxLength: maxLength, isPresented: $showLimitAlert)
                        .padding(24)
                }
            }
        }
    }
    
    private func startTimer() {
        isRunning = true
        timer = Foundation.Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
            
            if elapsedSeconds >= targetSeconds {
                completeCycle()
            }
        }
    }
    
    private func restartTimer() {
        stopTimer()
        days = 0
        elapsedSeconds = 0
        startTimer()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func completeCycle() {
        days += 1
        
        stopTimer()
        
        elapsedSeconds = 0
    }
    
    func action() {
        stopTimer()
    }
}

#Preview {
    Timer()
}
