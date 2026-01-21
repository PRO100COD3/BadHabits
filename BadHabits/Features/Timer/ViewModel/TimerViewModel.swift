//
//  TimerViewModel.swift
//  BadHabits
//
//  Created by Вадим Дзюба on 19.01.2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TimerViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var showLimitAlert = false
    @Published var isRunning = false
    @Published var days = 0
    @Published var elapsedSeconds: TimeInterval = 0
    @Published var shouldShowRestartDialog = false
    @Published var restartReason: String = ""
    @Published var showRestartReasonLimitAlert = false
    
    private var hasStarted = false
    private var restartReasonAlertHideTask: DispatchWorkItem?
    
    init(initialText: String = "") {
        self.text = initialText
    }
    
    private var timer: Foundation.Timer?
    let maxLength = 17
    let restartReasonMaxLength = 30
    private let targetSeconds: TimeInterval = 24 * 60 * 60
    private var alertHideTask: DispatchWorkItem?
    
    var progress: Double {
        min(elapsedSeconds / targetSeconds, 1.0)
    }
    
    var timeString: String {
        let hours = Int(elapsedSeconds) / 3600
        let minutes = (Int(elapsedSeconds) % 3600) / 60
        let seconds = Int(elapsedSeconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var canStartTimer: Bool {
        !text.isEmpty
    }
    
    var shouldShowRestart: Bool {
        hasStarted
    }
    
    func handleTextChange(_ newValue: String) {
        if newValue.count > maxLength {
            text = String(newValue.prefix(maxLength))
            showCharacterLimitAlert()
        } else {
            text = newValue
        }
    }
    
    func startTimer() {
        guard canStartTimer else { return }
        hasStarted = true
        isRunning = true
        timer = Foundation.Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                await self.tick()
            }
        }
    }
    
    func showRestartDialog() {
        withAnimation(.easeInOut(duration: 0.225)) {
            shouldShowRestartDialog = true
        }
    }
    
    func confirmRestart() {
        stopTimer()
        days = 0
        elapsedSeconds = 0
        restartReason = ""
        withAnimation(.easeInOut(duration: 0.18)) {
            shouldShowRestartDialog = false
        }
    }
    
    func cancelRestart() {
        restartReason = ""
        withAnimation(.easeInOut(duration: 0.18)) {
            shouldShowRestartDialog = false
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func close() {
        stopTimer()
    }
    
    private func tick() async {
        elapsedSeconds += 1
        
        if elapsedSeconds >= targetSeconds {
            completeCycle()
        }
    }
    
    private func completeCycle() {
        days += 1
        stopTimer()
        elapsedSeconds = 0
    }
    
    private func showCharacterLimitAlert() {
        guard !showLimitAlert else { return }
        
        showLimitAlert = true
        
        alertHideTask?.cancel()
        
        let hideTask = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.showLimitAlert = false
            }
        }
        alertHideTask = hideTask
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: hideTask)
    }
    
    func showRestartReasonCharacterLimitAlert() {
        guard !showRestartReasonLimitAlert else { return }
        
        showRestartReasonLimitAlert = true
        
        restartReasonAlertHideTask?.cancel()
        
        let hideTask = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.showRestartReasonLimitAlert = false
            }
        }
        restartReasonAlertHideTask = hideTask
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: hideTask)
    }
    
    deinit {
        timer?.invalidate()
        alertHideTask?.cancel()
        restartReasonAlertHideTask?.cancel()
    }
}
