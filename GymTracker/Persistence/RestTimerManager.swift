import Foundation
import SwiftUI
import Combine

@MainActor
public final class RestTimerManager: ObservableObject {
    public static let shared = RestTimerManager()
    
    @Published public var timeRemaining: Int = 0
    @Published public var initialDuration: Int = 90
    @Published public var isRunning: Bool = false
    @Published public var isPresented: Bool = false
    
    private var timer: AnyCancellable?
    
    public init() {}
    
    public var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public var progress: Double {
        guard initialDuration > 0 else { return 0 }
        return Double(timeRemaining) / Double(initialDuration)
    }
    
    public func start(duration: Int) {
        initialDuration = max(5, duration)
        timeRemaining = initialDuration
        isRunning = true
        isPresented = true
        
        timer?.cancel()
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    public func togglePause() {
        isRunning.toggle()
        if isRunning {
            timer?.cancel()
            timer = Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.tick()
                }
        } else {
            timer?.cancel()
        }
    }
    
    public func addTime(seconds: Int) {
        let newTime = max(0, timeRemaining + seconds)
        timeRemaining = newTime
        if newTime > initialDuration {
            initialDuration = newTime
        }
        if newTime == 0 {
            stop()
        }
    }
    
    public func reset() {
        timeRemaining = initialDuration
        isRunning = true
    }
    
    public func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
        timeRemaining = 0
        isPresented = false
    }
    
    private func tick() {
        guard isRunning else { return }
        if timeRemaining > 1 {
            timeRemaining -= 1
        } else if timeRemaining == 1 {
            timeRemaining = 0
            isRunning = false
            timer?.cancel()
            timer = nil
            // Fire completion haptics
            HapticFeedback.success()
        }
    }
}
