# Family Wordle

A tvOS party game. One puzzle fills the television, and the couch takes turns with the Siri Remote.

## Requirements

- A Mac with Xcode 15 or later
- The tvOS 17 simulator (any Apple TV model in the simulator is fine)

This project does not use Swift Package Manager or any third-party libraries. It is a single Xcode app target.

## Run it

1. Open `FamilyWordle.xcodeproj`.
2. Set the run destination to an Apple TV simulator.
3. Press Run.

Signing is set up so the simulator does not ask for a development team. To install on a physical Apple TV, open the target’s Signing & Capabilities tab, choose your team, and let Xcode manage signing.

## How to play on the remote

Focus moves with the Siri Remote. Click the touch surface to press the focused control.

- Letter keys fill the current row.
- **Guess** scores the word.
- **Delete** removes the last letter.
- In the simulator you can also type letters, and press Delete, on the Mac keyboard while it is a player’s turn.

A guess has to be five letters and in the built-in word list. A wrong-length or unknown word shakes the row and does not spend a guess.

Tile colors:

- Green: right letter, right spot
- Yellow: the letter is in the word, in the wrong spot
- Gray: the letter is not in the word

Duplicate letters are scored the way Wordle scores them. A second copy of a letter is yellow or green only when the answer has another copy left.

## Modes

**Solo.** Six guesses, one player. The daily puzzle updates your streak once per calendar day. Practice rounds do not.

**Family mode.** Two to six players share one grid. Each person makes a single guess, then the screen asks you to pass the remote. The player who solves it wins the round.

**Team mode.** The same shared grid, with two named sides (Parents and Kids, until you rename them).

Everyone gets six guesses in total, not six each. Solving on guess 1 is worth 6 household points, down to 1 point on guess 6. Those points are the ranking on the results screen and in Settings.

## Daily word

The daily answer is chosen on the Apple TV from the local date. Every device on the same calendar day gets the same word. There is no network call. Practice mode picks a different word from the same list so a demo is not stuck on today’s answer.

The order of `answers` in `WordBank.swift` is the rotation. Add new words at the end. Reordering the list changes which word falls on which date.

## What is saved

`UserDefaults` stores:

- Sound on or off
- The family-mode player count
- Whether the next setup opens on the daily word or a practice word
- The last names you used
- Solo streak, win rate, and guess distribution
- Household points for family and team names

Reset stats in Settings. The first press arms the button. The second press clears streaks and household points. Names and the sound setting stay.

## Project layout

```
FamilyWordle/
  App/                  Entry point
  Models/               Rules, players, tiles, keyboard keys
  Services/             Word list, scoring, sound, UserDefaults
  Theme/                Dark and light palettes, player colors
  ViewModels/           Turn state machine
  Views/                Menu, setup, game, handoff, results, settings
```

`GameViewModel` is the round. Solo stays on the board. Family and team start on the pass-the-remote screen, then alternate:

`handoff → playing → tile flip → handoff → … → results`

Leaving for the menu cancels an in-flight reveal so a half-finished guess is not written into the stats.

## Focus

Menu rows and the main actions use the system card button, which is the tvOS focus treatment (lift and highlight). The keyboard uses a custom focus style: the focused key turns white and scales up, because a full card chrome is too heavy on a dense grid. `@FocusState` moves focus to Ready between turns, back to the keyboard when the next player starts, and to New practice round on the results screen. Covered controls are disabled so the remote cannot land on them.
