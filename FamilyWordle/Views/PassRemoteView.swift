import SwiftUI

/// Full-screen beat between turns. The board stays dim behind the scrim so the
/// puzzle is still in the room, and the next name is impossible to miss.
struct PassRemoteView: View {
    let participant: Participant
    var namespace: Namespace.ID
    var focus: FocusState<GameFocus?>.Binding
    var onReady: () -> Void
    var onMenu: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.scrim.ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "appletvremote.gen2")
                    .font(.system(size: 54, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                    .accessibilityHidden(true)

                Text("Pass the remote")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.textSecondary)

                PlayerSwatch(colorIndex: participant.colorIndex, size: 84)
                    .matchedGeometryEffect(id: "turnPip", in: namespace)

                Text(participant.name)
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                    .foregroundStyle(PlayerColor.color(participant.colorIndex))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 40)

                Text("When you have it, make the next guess.")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.text)

                HStack(spacing: 20) {
                    Button(action: onReady) {
                        Text("Ready")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .padding(.horizontal, 54)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.card)
                    .focused(focus, equals: .ready)

                    Button(action: onMenu) {
                        Text("Menu")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 36)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.card)
                    .focused(focus, equals: .menu)
                }
                .padding(.top, 12)
            }
            .padding(48)
            .focusSection()
        }
        .accessibilityElement(children: .contain)
    }
}
