import SwiftUI

struct HangmanGameView: View {
    let onMenu: () -> Void

    @State private var state = HangmanGameState(round: HangmanCatalog.randomRound())
    @State private var showConfetti = false
    @State private var showVictory = false
    @State private var showGameOver = false

    private let backgroundColor = Color(red: 0.08, green: 0.14, blue: 0.28)
    private let cellColor = Color(red: 0.12, green: 0.20, blue: 0.36)
    private let accentColor = Color(red: 0.95, green: 0.35, blue: 0.55)

    private let keyboardRows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ñ"],
        ["Z", "X", "C", "V", "B", "N", "M"],
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                statsBar
                ScrollView {
                    VStack(spacing: 18) {
                        hangmanDrawing
                        wordDisplay
                        hintBox
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                keyboard
                actionBar
                Text(L10n.craftingAttribution)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.bottom, 6)
            }
            .background(backgroundColor.ignoresSafeArea())

            ConfettiView(isActive: showConfetti)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            if showVictory {
                overlayBackdrop
                Button(action: continueAfterVictory) {
                    victoryOverlay
                }
                .buttonStyle(.plain)
            }

            if showGameOver {
                overlayBackdrop
                Button(action: continueAfterLoss) {
                    gameOverOverlay
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: state.status) { _, status in
            switch status {
            case .playing:
                break
            case .won:
                withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                    showVictory = true
                }
                showConfetti = true
                GameSounds.shared.playVictory()
            case .lost:
                withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                    showGameOver = true
                }
                GameSounds.shared.playFailure()
            }
        }
    }

    private var overlayBackdrop: some View {
        Color.black.opacity(0.52)
            .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Text(L10n.appTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .italic()
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color(red: 0.06, green: 0.11, blue: 0.22))
    }

    private var statsBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                scoreBadge(title: L10n.hangmanWinsLabel, value: state.wins, color: .green)
                scoreBadge(title: L10n.hangmanLossesLabel, value: state.losses, color: .red)
            }

            Text(L10n.hangmanRemainingGuesses(state.remainingGuesses))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))

            Text(L10n.hangmanInstruction)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private func scoreBadge(title: String, value: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            Text("\(value)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.28))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.55), lineWidth: 1)
                )
        )
    }

    private var hangmanDrawing: some View {
        HangmanFigureView(stage: state.wrongCount)
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }

    private var wordDisplay: some View {
        let letters = state.displayLetters

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(letters.enumerated()), id: \.offset) { _, letter in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(cellColor)
                            .frame(width: 34, height: 44)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            }

                        if let letter {
                            Text(String(letter))
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
    }

    private var hintBox: some View {
        VStack(spacing: 6) {
            Text(L10n.hangmanHintTitle)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(accentColor)
            Text(state.round.hint)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
    }

    private var keyboard: some View {
        VStack(spacing: 6) {
            ForEach(keyboardRows, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(row, id: \.self) { key in
                        let letter = Character(key)
                        let isUsed = state.guessedLetters.contains(HangmanCatalog.normalizeLetter(letter))
                        let isCorrect = state.round.word.contains(where: {
                            HangmanCatalog.normalizeLetter($0) == HangmanCatalog.normalizeLetter(letter)
                        })

                        Button {
                            submitGuess(letter)
                        } label: {
                            Text(key)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(keyboardLetterColor(isUsed: isUsed, isCorrect: isCorrect))
                                .frame(minWidth: 28, minHeight: 34)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(keyboardBackground(isUsed: isUsed, isCorrect: isCorrect))
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(state.status != .playing || isUsed)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 0.06, green: 0.11, blue: 0.22))
    }

    private func keyboardLetterColor(isUsed: Bool, isCorrect: Bool) -> Color {
        guard isUsed else { return .white }
        return isCorrect ? .green : .red.opacity(0.85)
    }

    private func keyboardBackground(isUsed: Bool, isCorrect: Bool) -> Color {
        guard isUsed else { return Color.white.opacity(0.12) }
        return isCorrect ? Color.green.opacity(0.22) : Color.red.opacity(0.18)
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            circularButton(color: accentColor, icon: "arrow.clockwise") {
                restartSession()
                GameSounds.shared.playStart()
            }
            circularButton(color: .yellow, icon: "lightbulb.fill") {
                if state.applyHint() {
                    GameSounds.shared.playSuccess()
                } else {
                    GameSounds.shared.playFailure()
                }
            }
            circularButton(color: .blue, icon: "line.3.horizontal") {
                onMenu()
            }
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.05, green: 0.09, blue: 0.18))
    }

    private func circularButton(color: Color, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Circle().fill(color))
        }
        .buttonStyle(.plain)
    }

    private var victoryOverlay: some View {
        VStack(spacing: 10) {
            Text(L10n.hangmanVictoryTitle)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.hangmanVictorySubtitle(word: state.round.word))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
            Text(L10n.hangmanVictoryAction)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .background(overlayCard)
    }

    private var gameOverOverlay: some View {
        VStack(spacing: 10) {
            Text(L10n.hangmanGameOverTitle)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.hangmanGameOverSubtitle(word: state.round.word))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
            Text(L10n.hangmanGameOverAction)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .background(overlayCard)
    }

    private var overlayCard: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(accentColor, lineWidth: 2)
            )
    }

    private func submitGuess(_ letter: Character) {
        switch state.guess(letter) {
        case .correct:
            GameSounds.shared.playSuccess()
        case .wrong:
            GameSounds.shared.playFailure()
        case .ignored:
            break
        }
    }

    private func continueAfterVictory() {
        showVictory = false
        showConfetti = false
        state = state.advanceAfterWin()
        GameSounds.shared.playStart()
    }

    private func continueAfterLoss() {
        showGameOver = false
        state = state.advanceAfterLoss()
        GameSounds.shared.playStart()
    }

    private func restartSession() {
        state = HangmanGameState(round: HangmanCatalog.randomRound())
        showConfetti = false
        showVictory = false
        showGameOver = false
    }
}

private struct HangmanFigureView: View {
    let stage: Int

    var body: some View {
        Canvas { context, size in
            let stroke = StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            let color = Color.white.opacity(0.85)

            let baseX = size.width * 0.18
            let topY = size.height * 0.12
            let baseY = size.height * 0.88
            let beamX = size.width * 0.52
            let ropeX = size.width * 0.52
            let headY = size.height * 0.24
            let headRadius = size.width * 0.07
            let bodyTop = headY + headRadius * 2.2
            let bodyBottom = size.height * 0.58
            let armY = size.height * 0.38
            let legY = bodyBottom

            func line(from start: CGPoint, to end: CGPoint) {
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)
                context.stroke(path, with: .color(color), style: stroke)
            }

            line(from: CGPoint(x: baseX, y: baseY), to: CGPoint(x: baseX, y: topY))
            line(from: CGPoint(x: baseX, y: topY), to: CGPoint(x: beamX, y: topY))
            line(from: CGPoint(x: ropeX, y: topY), to: CGPoint(x: ropeX, y: headY))

            if stage >= 1 {
                let headRect = CGRect(
                    x: ropeX - headRadius,
                    y: headY,
                    width: headRadius * 2,
                    height: headRadius * 2
                )
                context.stroke(Path(ellipseIn: headRect), with: .color(color), style: stroke)
            }

            if stage >= 2 {
                line(from: CGPoint(x: ropeX, y: bodyTop), to: CGPoint(x: ropeX, y: bodyBottom))
            }

            if stage >= 3 {
                line(from: CGPoint(x: ropeX, y: armY), to: CGPoint(x: ropeX - headRadius * 1.8, y: armY + headRadius * 1.2))
            }

            if stage >= 4 {
                line(from: CGPoint(x: ropeX, y: armY), to: CGPoint(x: ropeX + headRadius * 1.8, y: armY + headRadius * 1.2))
            }

            if stage >= 5 {
                line(from: CGPoint(x: ropeX, y: legY), to: CGPoint(x: ropeX - headRadius * 1.2, y: legY + headRadius * 2))
            }

            if stage >= 6 {
                line(from: CGPoint(x: ropeX, y: legY), to: CGPoint(x: ropeX + headRadius * 1.2, y: legY + headRadius * 2))
            }
        }
    }
}

#Preview {
    HangmanGameView(onMenu: {})
}
