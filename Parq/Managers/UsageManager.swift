import Combine
import Foundation

@MainActor
final class UsageManager: ObservableObject {
    @Published private(set) var usedSessions: Int
    @Published private(set) var shareUnlockCount: Int
    @Published private(set) var isLifetimeUnlocked: Bool

    let baseFreeSessions = 3
    let maxShareUnlocks = 2
    let sessionsPerShare = 1

    private let defaults: UserDefaults
    private let usedSessionsKey = "parq.usedSessions"
    private let shareUnlockCountKey = "parq.shareUnlockCount"
    private let lifetimeUnlockedKey = "parq.isLifetimeUnlocked"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.usedSessions = defaults.integer(forKey: usedSessionsKey)
        self.shareUnlockCount = defaults.integer(forKey: shareUnlockCountKey)
        self.isLifetimeUnlocked = defaults.bool(forKey: lifetimeUnlockedKey)
    }

    var totalFreeSessions: Int {
        baseFreeSessions + (shareUnlockCount * sessionsPerShare)
    }

    var remainingSessions: Int {
        isLifetimeUnlocked ? .max : max(0, totalFreeSessions - usedSessions)
    }

    var canStartNewSession: Bool {
        isLifetimeUnlocked || remainingSessions > 0
    }

    var canShareForExtraSession: Bool {
        !isLifetimeUnlocked && shareUnlockCount < maxShareUnlocks
    }

    func consumeSession() {
        guard !isLifetimeUnlocked else { return }
        guard remainingSessions > 0 else { return }

        usedSessions += 1
        defaults.set(usedSessions, forKey: usedSessionsKey)
    }

    @discardableResult
    func unlockSessionViaShare() -> Bool {
        guard canShareForExtraSession else { return false }

        shareUnlockCount += 1
        defaults.set(shareUnlockCount, forKey: shareUnlockCountKey)
        return true
    }

    func unlockLifetime() {
        setLifetimeUnlocked(true)
    }

    func setLifetimeUnlocked(_ isUnlocked: Bool) {
        isLifetimeUnlocked = isUnlocked
        defaults.set(isUnlocked, forKey: lifetimeUnlockedKey)
    }
}
