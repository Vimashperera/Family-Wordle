import AudioToolbox

/// Short system sounds. Visual feedback is the real signal on a TV;
/// these are optional and gated by Settings. Invalid sound IDs simply play nothing.
enum SoundPlayer {
    enum Effect {
        case tap
        case reject
        case success
        case miss

        var soundID: SystemSoundID {
            switch self {
            case .tap: 1104
            case .reject: 1053
            case .success: 1025
            case .miss: 1073
            }
        }
    }

    static func play(_ effect: Effect, enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(effect.soundID)
    }
}
