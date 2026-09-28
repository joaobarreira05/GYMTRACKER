import Foundation
import UserNotifications
import SwiftUI
import Combine

public enum NotificationTimingPreference: String, CaseIterable, Identifiable, Codable {
    case twentyFourHours = "24 Horas"
    case fourHours = "4 Horas"
    case both = "24h e 4h (Recomendado)"
    
    public var id: String { rawValue }
}

@MainActor
public final class CertificateExpirationManager: ObservableObject {
    public static let shared = CertificateExpirationManager()
    
    public static let notification24hId = "gymtracker_cert_expiration_24h"
    public static let notification4hId = "gymtracker_cert_expiration_4h"
    public static let testNotificationId = "gymtracker_cert_test_notification"
    
    private let fallbackDays: Double = 7.0
    private let userDefaultsKeyBuildDate = "GymTracker_AppBuildOrInstallDate"
    private let userDefaultsKeyNotificationEnabled = "GymTracker_CertNotificationEnabled"
    private let userDefaultsKeyTimingPreference = "GymTracker_CertTimingPreference"
    
    @Published public var expirationDate: Date = Date().addingTimeInterval(7 * 24 * 3600)
    @Published public var isUsingFallback: Bool = false
    @Published public var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published public var isNotificationScheduled: Bool = false
    @Published public var timingPreference: NotificationTimingPreference {
        didSet {
            UserDefaults.standard.set(timingPreference.rawValue, forKey: userDefaultsKeyTimingPreference)
            if isNotificationEnabled {
                scheduleExpirationNotification()
            }
        }
    }
    @Published public var isNotificationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isNotificationEnabled, forKey: userDefaultsKeyNotificationEnabled)
            if isNotificationEnabled {
                scheduleExpirationNotification()
            } else {
                cancelScheduledNotification()
            }
        }
    }
    
    private init() {
        let savedEnabled = UserDefaults.standard.object(forKey: userDefaultsKeyNotificationEnabled) as? Bool ?? true
        self.isNotificationEnabled = savedEnabled
        
        if let savedPref = UserDefaults.standard.string(forKey: userDefaultsKeyTimingPreference),
           let pref = NotificationTimingPreference(rawValue: savedPref) {
            self.timingPreference = pref
        } else {
            self.timingPreference = .twentyFourHours
        }
        
        refreshCertificateInfo()
    }
    
    // MARK: - Certificate Parsing & Calculation
    public func refreshCertificateInfo() {
        if let realExpiration = parseProvisioningExpirationDate() {
            self.expirationDate = realExpiration
            self.isUsingFallback = false
        } else {
            // Fallback: build date or first launch date + 7 days
            let baseDate = determineBaseDate()
            self.expirationDate = baseDate.addingTimeInterval(fallbackDays * 24 * 3600)
            self.isUsingFallback = true
        }
        
        checkNotificationAuthorization()
    }
    
    private func parseProvisioningExpirationDate() -> Date? {
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let candidates: [URL] = [
            Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
            bundleURL.appendingPathComponent("embedded.mobileprovision"),
            bundleURL.appendingPathComponent("Frameworks/embedded.mobileprovision")
        ].compactMap { $0 }
        
        for candidate in candidates where fileManager.fileExists(atPath: candidate.path) {
            guard let data = try? Data(contentsOf: candidate),
                  let raw = String(data: data, encoding: .isoLatin1) else {
                continue
            }
            guard let start = raw.range(of: "<?xml"),
                  let end = raw.range(of: "</plist>") else {
                continue
            }
            let xmlSubstring = String(raw[start.lowerBound..<end.upperBound])
            guard let xmlData = xmlSubstring.data(using: .utf8),
                  let plist = try? PropertyListSerialization.propertyList(from: xmlData, options: [], format: nil) as? [String: Any],
                  let expDate = plist["ExpirationDate"] as? Date else {
                continue
            }
            return expDate
        }
        return nil
    }
    
    private func determineBaseDate() -> Date {
        // Try executable creation date
        if let exeURL = Bundle.main.executableURL,
           let attrs = try? FileManager.default.attributesOfItem(atPath: exeURL.path),
           let creationDate = attrs[.creationDate] as? Date {
            return creationDate
        }
        // Try saved install date or set now
        if let saved = UserDefaults.standard.object(forKey: userDefaultsKeyBuildDate) as? Date {
            return saved
        }
        let now = Date()
        UserDefaults.standard.set(now, forKey: userDefaultsKeyBuildDate)
        return now
    }
    
    // MARK: - Computed Properties
    public var timeRemaining: TimeInterval {
        expirationDate.timeIntervalSince(Date())
    }
    
    public var isExpired: Bool {
        timeRemaining <= 0
    }
    
    public var isExpiringSoon: Bool {
        // Expiring within 24 hours
        timeRemaining > 0 && timeRemaining <= (24 * 3600)
    }
    
    public var remainingFormatted: String {
        let seconds = timeRemaining
        if seconds <= 0 {
            return "Expirado"
        }
        let days = Int(seconds) / 86400
        let hours = (Int(seconds) % 86400) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h restantes"
        } else if hours > 0 {
            return "\(hours)h \(minutes)min restantes"
        } else {
            return "\(minutes)min restantes"
        }
    }
    
    public var notificationTargetDate24h: Date {
        expirationDate.addingTimeInterval(-24 * 3600)
    }
    
    public var notificationTargetDate4h: Date {
        expirationDate.addingTimeInterval(-4 * 3600)
    }
    
    public var primaryNotificationTargetDate: Date {
        switch timingPreference {
        case .twentyFourHours, .both:
            return notificationTargetDate24h
        case .fourHours:
            return notificationTargetDate4h
        }
    }
    
    // MARK: - Notification Management
    public func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            Task { @MainActor in
                self?.notificationStatus = settings.authorizationStatus
                self?.checkIfNotificationIsPending()
            }
        }
    }
    
    private func checkIfNotificationIsPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            let ids = [Self.notification24hId, Self.notification4hId]
            let isPending = requests.contains { ids.contains($0.identifier) }
            Task { @MainActor in
                self?.isNotificationScheduled = isPending
            }
        }
    }
    
    public func requestPermissionAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            Task { @MainActor in
                self?.checkNotificationAuthorization()
                if granted && (self?.isNotificationEnabled ?? true) {
                    self?.scheduleExpirationNotification()
                }
            }
        }
    }
    
    public func scheduleExpirationNotification() {
        guard isNotificationEnabled else { return }
        
        // Remove previous notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            Self.notification24hId,
            Self.notification4hId
        ])
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "HH:mm 'de' d 'de' MMMM"
        let expString = formatter.string(from: expirationDate)
        
        var scheduledAny = false
        
        // Schedule 24h notification
        if timingPreference == .twentyFourHours || timingPreference == .both {
            let target24h = notificationTargetDate24h
            let interval24h = target24h.timeIntervalSince(Date())
            
            if interval24h > 0 {
                let content = UNMutableNotificationContent()
                content.title = "⚠️ Certificado do GymTracker Expira em 24 Horas"
                content.subtitle = "Expira amanhã às \(expString)"
                content.body = "Conecta o teu iPhone ao Mac e clica em Run no Xcode (Cmd+R) para renovar por mais 7 dias. Os teus treinos continuam salvos!"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval24h, repeats: false)
                let request = UNNotificationRequest(identifier: Self.notification24hId, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { _ in }
                scheduledAny = true
            }
        }
        
        // Schedule 4h notification
        if timingPreference == .fourHours || timingPreference == .both {
            let target4h = notificationTargetDate4h
            let interval4h = target4h.timeIntervalSince(Date())
            
            if interval4h > 0 {
                let content = UNMutableNotificationContent()
                content.title = "🚨 Último Aviso: Certificado a Expirar em 4 Horas!"
                content.subtitle = "Expira hoje às \(expString)"
                content.body = "O GymTracker vai expirar em breve. Liga o iPhone ao Mac e clica em Run no Xcode (Cmd+R) para renovar antes do próximo treino!"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval4h, repeats: false)
                let request = UNNotificationRequest(identifier: Self.notification4hId, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { _ in }
                scheduledAny = true
            }
        }
        
        self.isNotificationScheduled = scheduledAny
    }
    
    public func cancelScheduledNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            Self.notification24hId,
            Self.notification4hId
        ])
        isNotificationScheduled = false
    }
    
    public func sendTestNotification(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "⚠️ Teste: Certificado a Expirar (Aviso 24 Horas)"
            content.subtitle = "Notificação de Demonstração"
            content.body = "Este é um teste do aviso de expiração de 24 horas do GymTracker. Quando faltar 1 dia real, receberás este alerta para ligar o iPhone ao Mac e renovar no Xcode!"
            content.sound = .default
            
            // Trigger in 5 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: Self.testNotificationId, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    completion(error == nil)
                }
            }
        }
    }
}
