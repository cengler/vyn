import SwiftUI

struct CrosswordGameView: View {
    let onMenu: () -> Void

    @State private var state = CrosswordGameState(puzzle: CrosswordCatalog.randomPuzzle())
    @State private var showConfetti = false
    @State private var showVictory = false

    private let backgroundColor = Color(red: 0.08, green: 0.14, blue: 0.28)
    private let cellColor = Color(red: 0.12, green: 0.20, blue: 0.36)
    private let blockColor = Color(red: 0.05, green: 0.09, blue: 0.18)
    private let accentColor = Color(red: 0.95, green: 0.35, blue: 0.55)
    private let spacing: CGFloat = 2

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
                    VStack(spacing: 14) {
                        gridSection
                        activeClue
                        cluesList
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
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
                Color.black.opacity(0.52)
                    .ignoresSafeArea()

                Button(action: onMenu) {
                    victoryOverlay
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: state.isComplete) { _, isComplete in
            guard isComplete else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                showVictory = true
            }
            showConfetti = true
            GameSounds.shared.playVictory()
        }
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
        VStack(spacing: 6) {
            HStack {
                Text(L10n.crosswordProgress(solved: state.solvedEntryCount, total: state.totalEntries))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                if state.hintsUsed > 0 {
                    Text(L10n.crosswordHintsUsed(state.hintsUsed))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }

            Text(L10n.crosswordInstruction)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var gridSection: some View {
        GeometryReader { geo in
            let puzzle = state.puzzle
            let cellSize = min(
                (geo.size.width - spacing * CGFloat(puzzle.spec.cols - 1)) / CGFloat(puzzle.spec.cols),
                42
            )
            let fontSize = min(18, max(11, cellSize * 0.52))
            let numberSize = min(10, max(7, cellSize * 0.24))

            VStack(spacing: spacing) {
                ForEach(0..<puzzle.spec.rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<puzzle.spec.cols, id: \.self) { col in
                            let position = GridPosition(row: row, col: col)
                            cellView(
                                position: position,
                                cellSize: cellSize,
                                fontSize: fontSize,
                                numberSize: numberSize
                            )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: gridHeight)
    }

    private var gridHeight: CGFloat {
        let puzzle = state.puzzle
        let cellSize: CGFloat = 36
        return cellSize * CGFloat(puzzle.spec.rows) + spacing * CGFloat(max(puzzle.spec.rows - 1, 0)) + 8
    }

    @ViewBuilder
    private func cellView(
        position: GridPosition,
        cellSize: CGFloat,
        fontSize: CGFloat,
        numberSize: CGFloat
    ) -> some View {
        let puzzle = state.puzzle

        if puzzle.isBlock(position) {
            RoundedRectangle(cornerRadius: 4)
                .fill(blockColor)
                .frame(width: cellSize, height: cellSize)
        } else {
            let isSelected = state.selectedCell == position
            let isActive = state.isActiveCell(position)
            let isCorrect = isCorrectCell(position)
            let letter = state.displayLetter(at: position)

            Button {
                state.selectCell(position)
                GameSounds.shared.playTap()
            } label: {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? accentColor.opacity(0.35) : cellColor)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    isSelected ? accentColor : (isActive ? Color.white.opacity(0.35) : Color.clear),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        }

                    if let number = puzzle.cellNumbers[position] {
                        Text("\(number)")
                            .font(.system(size: numberSize, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(3)
                    }

                    Text(letter.map(String.init) ?? "")
                        .font(.system(size: fontSize, weight: .bold, design: .rounded))
                        .foregroundStyle(isCorrect ? .green : .white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: cellSize, height: cellSize)
            }
            .buttonStyle(.plain)
        }
    }

    private func isCorrectCell(_ position: GridPosition) -> Bool {
        guard let typed = state.displayLetter(at: position),
              let expected = state.puzzle.solutionLetter(at: position) else { return false }
        return typed == expected
    }

    private var activeClue: some View {
        Group {
            if let entry = state.activeEntry {
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.direction == .across
                         ? L10n.crosswordAcrossLabel(number: entry.number)
                         : L10n.crosswordDownLabel(number: entry.number))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(accentColor)
                    Text(entry.clue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                )
            }
        }
    }

    private var cluesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.crosswordCluesTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))

            ForEach(state.puzzle.entries) { entry in
                Button {
                    state.selectEntry(entry)
                    GameSounds.shared.playTap()
                } label: {
                    HStack(alignment: .top, spacing: 8) {
                        Text(entry.direction == .across
                         ? L10n.crosswordAcrossLabel(number: entry.number)
                         : L10n.crosswordDownLabel(number: entry.number))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(accentColor)
                            .frame(width: 34, alignment: .leading)

                        Text(entry.clue)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(state.completedEntryIDs.contains(entry.id) ? 0.45 : 0.9))
                            .strikethrough(state.completedEntryIDs.contains(entry.id), color: accentColor)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var keyboard: some View {
        VStack(spacing: 6) {
            ForEach(keyboardRows, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            state.enterLetter(Character(key))
                            GameSounds.shared.playTap()
                        } label: {
                            Text(key)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(minWidth: 28, minHeight: 34)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.12))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                state.deleteLetter()
                GameSounds.shared.playTap()
            } label: {
                Label(L10n.crosswordDelete, systemImage: "delete.left")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 0.06, green: 0.11, blue: 0.22))
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            circularButton(color: accentColor, icon: "arrow.clockwise") {
                restartGame()
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
            Text(L10n.crosswordVictoryTitle)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.crosswordVictorySubtitle)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Text(L10n.crosswordVictoryAction)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accentColor, lineWidth: 2)
                )
        )
    }

    private func restartGame() {
        state = CrosswordGameState(puzzle: CrosswordCatalog.randomPuzzle())
        showConfetti = false
        showVictory = false
    }
}

#Preview {
    CrosswordGameView(onMenu: {})
}
