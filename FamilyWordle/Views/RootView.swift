import SwiftUI

/// Owns navigation. The game view model lives only while a round is on screen.
struct RootView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var store: PersistenceStore

    @State private var screen: AppScreen = .menu
    @State private var game: GameViewModel?

    var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()
            content
        }
        .environment(\.palette, palette)
        .animation(.easeInOut(duration: 0.28), value: screen)
    }

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .menu:
            MainMenuView(
                onSolo: { show(.setup(.solo)) },
                onFamily: { show(.setup(.family)) },
                onTeam: { show(.setup(.team)) },
                onHowToPlay: { show(.howToPlay) },
                onSettings: { show(.settings) }
            )
        case .setup(let mode):
            PlayerSetupView(mode: mode, onBack: { show(.menu) }) { participants, daily in
                beginGame(mode: mode, participants: participants, daily: daily)
            }
        case .howToPlay:
            HowToPlayView(onBack: { show(.menu) })
        case .settings:
            SettingsView(onBack: { show(.menu) })
        case .playing:
            if let game {
                GameView(model: game, onMenu: leaveGame)
            }
        }
    }

    private var palette: Palette {
        Palette.resolve(colorScheme)
    }

    private func show(_ next: AppScreen) {
        withAnimation(.easeInOut(duration: 0.28)) {
            screen = next
        }
    }

    private func beginGame(mode: GameMode, participants: [Participant], daily: Bool) {
        let model = GameViewModel(
            mode: mode,
            participants: participants,
            usesDailyWord: daily,
            store: store
        )
        game = model
        show(.playing)
    }

    private func leaveGame() {
        game?.abandon()
        game = nil
        show(.menu)
    }
}

enum AppScreen: Equatable {
    case menu
    case setup(GameMode)
    case howToPlay
    case settings
    case playing
}
