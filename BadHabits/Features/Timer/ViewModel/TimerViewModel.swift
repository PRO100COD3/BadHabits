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
    
    private var startDate: Date?
    private var savedDays: Int = 0
    private var savedElapsedSeconds: TimeInterval = 0
    
    private let userDefaults = UserDefaults.standard
    private let startDateKey = "TimerStartDate"
    private let savedDaysKey = "TimerSavedDays"
    private let savedElapsedSecondsKey = "TimerSavedElapsedSeconds"
    private let isRunningKey = "TimerIsRunning"
    private let timerTextKey = "TimerText"
    
    init(initialText: String = "") {
        self.text = initialText
        loadTimerState()
        setupNotifications()
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
        
        userDefaults.set(text, forKey: timerTextKey)
        
        if isRunning {
            saveTimerState()
        }
    }
    
    func startTimer() {
        hasStarted = true
        isRunning = true
        
        savedDays = days
        savedElapsedSeconds = elapsedSeconds
        
        if startDate == nil {
            startDate = Date()
        }
        
        saveTimerState()
        
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
        let wasRunning = isRunning
        stopTimer()
        days = 0
        elapsedSeconds = 0
        restartReason = ""
        startDate = nil
        savedDays = 0
        savedElapsedSeconds = 0
        clearTimerState()
        
        if wasRunning {
            startTimer()
        }
        
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
        startDate = nil
        clearTimerState()
    }
    
    func close() {
        stopTimer()
    }
    
    private func tick() async {
        updateElapsedTime()
        
        if elapsedSeconds >= targetSeconds {
            completeCycle()
        }
    }
    
    private func updateElapsedTime() {
        guard let startDate = startDate else { return }
        
        let currentTime = Date()
        let totalElapsed = currentTime.timeIntervalSince(startDate) + savedElapsedSeconds
        
        let fullCycles = Int(totalElapsed / targetSeconds)
        days = savedDays + fullCycles
        
        elapsedSeconds = totalElapsed.truncatingRemainder(dividingBy: targetSeconds)
    }
    
    private func completeCycle() {
        days += 1
        stopTimer()
        elapsedSeconds = 0
    }
        
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                await self?.applicationWillEnterForeground()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                await self?.applicationDidEnterBackground()
            }
        }
    }
    
    @MainActor
    private func applicationWillEnterForeground() async {
        if isRunning {
            updateElapsedTime()
            if timer == nil {
                timer = Foundation.Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    Task { @MainActor in
                        await self.tick()
                    }
                }
            }
        }
    }
    
    @MainActor
    private func applicationDidEnterBackground() async {
        if isRunning {
            updateElapsedTime()
            saveTimerState()
        }
    }
    
    private func loadTimerState() {
        if let savedStartDate = userDefaults.object(forKey: startDateKey) as? Date {
            startDate = savedStartDate
            savedDays = userDefaults.integer(forKey: savedDaysKey)
            savedElapsedSeconds = userDefaults.double(forKey: savedElapsedSecondsKey)
            let wasRunning = userDefaults.bool(forKey: isRunningKey)
            isRunning = wasRunning
            hasStarted = wasRunning
            
            if let savedText = userDefaults.string(forKey: timerTextKey) {
                if text.isEmpty {
                    text = savedText
                }
            }
            
            if wasRunning {
                updateElapsedTime()
                timer = Foundation.Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    Task { @MainActor in
                        await self.tick()
                    }
                }
            }
        }
    }
    
    private func saveTimerState() {
        if let startDate = startDate {
            userDefaults.set(startDate, forKey: startDateKey)
            userDefaults.set(savedDays, forKey: savedDaysKey)
            userDefaults.set(savedElapsedSeconds, forKey: savedElapsedSecondsKey)
            userDefaults.set(isRunning, forKey: isRunningKey)
            userDefaults.set(text, forKey: timerTextKey)
        }
    }
    
    nonisolated private func saveTimerStateSync() {
        let defaults = UserDefaults.standard
        if let savedStartDate = defaults.object(forKey: startDateKey) as? Date {
            let currentTime = Date()
            let savedDaysValue = defaults.integer(forKey: savedDaysKey)
            let savedElapsedValue = defaults.double(forKey: savedElapsedSecondsKey)
            let totalElapsed = currentTime.timeIntervalSince(savedStartDate) + savedElapsedValue
            let fullCycles = Int(totalElapsed / targetSeconds)
            let finalDays = savedDaysValue + fullCycles
            let finalElapsed = totalElapsed.truncatingRemainder(dividingBy: targetSeconds)
            
            defaults.set(savedStartDate, forKey: startDateKey)
            defaults.set(finalDays, forKey: savedDaysKey)
            defaults.set(finalElapsed, forKey: savedElapsedSecondsKey)
            defaults.set(true, forKey: isRunningKey)
        }
    }
    
    private func clearTimerState() {
        userDefaults.removeObject(forKey: startDateKey)
        userDefaults.removeObject(forKey: savedDaysKey)
        userDefaults.removeObject(forKey: savedElapsedSecondsKey)
        userDefaults.removeObject(forKey: isRunningKey)
        userDefaults.removeObject(forKey: timerTextKey)
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
        NotificationCenter.default.removeObserver(self)
        
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: isRunningKey) {
            saveTimerStateSync()
        }
    }
}
