import Combine
import Foundation

struct AppSettings: Codable, Equatable {
    var soundEnabled: Bool
    var familyPlayerCount: Int
    var preferDailyWord: Bool

    static let `default` = AppSettings(
        soundEnabled: true,
        familyPlayerCount: 3,
        preferDailyWord: true
    )
}

struct SoloStats: Codable, Equatable {
    var played: Int
    var wins: Int
    var currentStreak: Int
    var maxStreak: Int
    /// Index 0 is a solve on guess 1.
    var distribution: [Int]

    static let empty = SoloStats(
        played: 0,
        wins: 0,
        currentStreak: 0,
        maxStreak: 0,
        distribution: Array(repeating: 0, count: GameRules.maxGuesses)
    )

    var winRate: Int {
        guard played > 0 else { return 0 }
        return Int((Double(wins) / Double(played) * 100).rounded())
    }
}

struct HouseholdRecord: Codable, Equatable {
    var wins: Int = 0
    var points: Int = 0
    var played: Int = 0
}

/// Local save for settings, solo streaks, household points, and the names last used
/// on the couch. There is no account and no network.
@MainActor
final class PersistenceStore: ObservableObject {
    @Published var settings: AppSettings {
        didSet { save(settings, key: Keys.settings) }
    }

    @Published private(set) var soloStats: SoloStats
    @Published private(set) var records: [String: HouseholdRecord]
    @Published private(set) var savedFamilyNames: [String]
    @Published private(set) var savedTeamNames: [String]

    private let defaults: UserDefaults
    private var lastDailyKey: String?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        settings = Self.load(AppSettings.self, key: Keys.settings, from: defaults) ?? .default
        soloStats = Self.load(SoloStats.self, key: Keys.soloStats, from: defaults) ?? .empty
        records = Self.load([String: HouseholdRecord].self, key: Keys.records, from: defaults) ?? [:]
        savedFamilyNames = Self.load([String].self, key: Keys.familyNames, from: defaults) ?? []
        savedTeamNames = Self.load([String].self, key: Keys.teamNames, from: defaults) ?? []
        lastDailyKey = defaults.string(forKey: Keys.lastDaily)
        settings.familyPlayerCount = min(GameRules.maxPlayers, max(GameRules.minPlayers, settings.familyPlayerCount))
        if soloStats.distribution.count != GameRules.maxGuesses {
            soloStats.distribution = Array(repeating: 0, count: GameRules.maxGuesses)
        }
    }

    static func preview() -> PersistenceStore {
        let defaults = UserDefaults(suiteName: "FamilyWordle.Preview") ?? .standard
        return PersistenceStore(defaults: defaults)
    }

    var rankedRecords: [(name: String, record: HouseholdRecord)] {
        records
            .map { (name: $0.key, record: $0.value) }
            .sorted { lhs, rhs in
                if lhs.record.points != rhs.record.points { return lhs.record.points > rhs.record.points }
                if lhs.record.wins != rhs.record.wins { return lhs.record.wins > rhs.record.wins }
                return lhs.name < rhs.name
            }
    }

    func saveFamilyNames(_ names: [String]) {
        savedFamilyNames = names
        save(names, key: Keys.familyNames)
    }

    func saveTeamNames(_ names: [String]) {
        savedTeamNames = names
        save(names, key: Keys.teamNames)
    }

    /// Solo streaks count the daily puzzle once per calendar day.
    /// Practice rounds are not written into the streak.
    /// Family and team games always update the household table.
    func recordRound(
        mode: GameMode,
        participants: [Participant],
        solved: Bool,
        points: Int,
        guessesUsed: Int,
        daily: Bool
    ) {
        switch mode {
        case .solo:
            guard daily else { return }
            let today = WordBank.dayKey()
            guard lastDailyKey != today else { return }
            soloStats.played += 1
            if solved {
                soloStats.wins += 1
                soloStats.currentStreak += 1
                soloStats.maxStreak = max(soloStats.maxStreak, soloStats.currentStreak)
                let bucket = guessesUsed - 1
                if soloStats.distribution.indices.contains(bucket) {
                    soloStats.distribution[bucket] += 1
                }
            } else {
                soloStats.currentStreak = 0
            }
            lastDailyKey = today
            defaults.set(today, forKey: Keys.lastDaily)
            save(soloStats, key: Keys.soloStats)
        case .family, .team:
            for person in participants {
                var record = records[person.name] ?? HouseholdRecord()
                record.played += 1
                if person.solvedTheWord {
                    record.wins += 1
                    record.points += points
                }
                records[person.name] = record
            }
            save(records, key: Keys.records)
        }
    }

    func resetStats() {
        soloStats = .empty
        records = [:]
        lastDailyKey = nil
        defaults.removeObject(forKey: Keys.lastDaily)
        save(soloStats, key: Keys.soloStats)
        save(records, key: Keys.records)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private enum Keys {
        static let settings = "fw.settings"
        static let soloStats = "fw.soloStats"
        static let records = "fw.records"
        static let familyNames = "fw.familyNames"
        static let teamNames = "fw.teamNames"
        static let lastDaily = "fw.lastDaily"
    }
}
