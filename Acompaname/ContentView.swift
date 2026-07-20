import SwiftUI

struct ContentView: View {
    @State private var puzzle = WordSearchGenerator.newGame()
    @State private var selection: [GridPosition] = []
    @State private var foundWords: Set<String> = []
    @State private var showConfetti = false
    @State private var showVictory = false
    @State private var soundEnabled = true
    @State private var firstLetterHints: Set<GridPosition> = []
    @State private var layout = GridLayoutMetrics.default
    @State private var layoutReady = false
    @State private var showMenu = true
    @State private var currentMode: GameMode?

    private let backgroundColor = Color(red: 0.08, green: 0.14, blue: 0.28)
    private let cellColor = Color(red: 0.12, green: 0.20, blue: 0.36)
    private let accentColor = Color(red: 0.95, green: 0.35, blue: 0.55)
    private let hintColor = Color.yellow
    private let spacing: CGFloat = 1

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            if let mode = currentMode, !showMenu {
                switch mode {
                case .crafting:
                    CraftingGameView(onMenu: openMenu)
                        .id("crafting")
                case .memory:
                    MemoryGameView(onMenu: openMenu)
                        .id("memory")
                case .taboo:
                    TabooGameView(onMenu: openMenu)
                        .id("taboo")
                case .minecraft:
                    wordSearchView
                        .id(mode.rawValue)
                case .merge2048:
                    Merge2048GameView(onMenu: openMenu)
                        .id("merge2048")
                case .crossword:
                    CrosswordGameView(onMenu: openMenu)
                        .id("crossword")
                case .hangman:
                    HangmanGameView(onMenu: openMenu)
                        .id("hangman")
                }
            }

            if currentMode?.isWordSearch == true, !showMenu {
                ConfettiView(isActive: showConfetti)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if showVictory, currentMode?.isWordSearch == true, !showMenu {
                Color.black.opacity(0.52)
                    .ignoresSafeArea()
                    .transition(.opacity)

                Button(action: openMenu) {
                    victoryOverlay
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }

            Color.black.opacity(showMenu ? 0.58 : 0)
                .ignoresSafeArea()
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showMenu)
                .allowsHitTesting(showMenu)

            menuOverlay
                .opacity(showMenu ? 1 : 0)
                .scaleEffect(showMenu ? 1 : 0.96)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showMenu)
                .allowsHitTesting(showMenu)
        }
        .onAppear {
            GameSounds.shared.isEnabled = soundEnabled
        }
        .preferredColorScheme(.dark)
    }

    private var wordSearchView: some View {
        VStack(spacing: 0) {
            Text(L10n.appTitle)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .italic()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 0.06, green: 0.11, blue: 0.22))

            GeometryReader { geo in
                gridView
                    .frame(width: layout.gridWidth, height: layout.gridHeight, alignment: .topLeading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        updateLayout(width: geo.size.width, height: geo.size.height)
                    }
                    .onChange(of: geo.size) { _, newSize in
                        updateLayout(width: newSize.width, height: newSize.height)
                    }
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 10)
            .padding(.top, 8)

            wordList
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 10)

            bottomBar
        }
    }

    private var victoryOverlay: some View {
        VStack(spacing: 10) {
            Text(L10n.wordSearchVictoryTitle)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.wordSearchVictorySubtitle)
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Text(L10n.wordSearchVictoryAction)
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
        .transition(.scale.combined(with: .opacity))
    }

    private var menuOverlay: some View {
        VStack(spacing: 18) {
            Text(L10n.chooseMode)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(L10n.appTitle)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            VStack(spacing: 12) {
                ForEach(GameMode.allCases) { mode in
                    Button {
                        selectMode(mode)
                    } label: {
                        VStack(spacing: 4) {
                            Text(mode.title)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Text(mode.subtitle)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .opacity(0.85)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(menuColor(for: mode))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(L10n.menuAttribution)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.06, green: 0.11, blue: 0.22).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }

    private func menuColor(for mode: GameMode) -> Color {
        switch mode {
        case .minecraft: Color.green.opacity(0.85)
        case .crafting: Color.orange.opacity(0.9)
        case .memory: Color.purple.opacity(0.88)
        case .taboo: Color.teal.opacity(0.88)
        case .merge2048: Color.brown.opacity(0.85)
        case .crossword: Color.indigo.opacity(0.88)
        case .hangman: Color.cyan.opacity(0.82)
        }
    }

    private var gridView: some View {
        let rowCount = puzzle.rows
        let columnCount = puzzle.cols
        let cellSize = layout.cellSize
        let fontSize = min(22, max(14, cellSize * 0.46))

        return ZStack {
            VStack(spacing: spacing) {
                ForEach(0..<rowCount, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columnCount, id: \.self) { col in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(cellColor)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }

            ForEach(puzzle.placements.filter { foundWords.contains($0.word) }, id: \.id) { placement in
                highlightStrip(positions: placement.cells, cellSize: cellSize, color: accentColor, opacity: 0.85)
            }

            ForEach(Array(firstLetterHints), id: \.self) { position in
                highlightStrip(positions: [position], cellSize: cellSize, color: hintColor, opacity: 0.92)
            }

            if !selection.isEmpty {
                highlightStrip(positions: selection, cellSize: cellSize, color: accentColor, opacity: 0.55)
            }

            VStack(spacing: spacing) {
                ForEach(0..<rowCount, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columnCount, id: \.self) { col in
                            let letter = puzzle.grid[row][col]
                            Text(String(letter))
                                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .frame(width: layout.gridWidth, height: layout.gridHeight, alignment: .topLeading)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard !showVictory, !showMenu else { return }
                    if let position = gridPosition(
                        at: value.location,
                        cellSize: cellSize,
                        rows: rowCount,
                        columns: columnCount
                    ) {
                        updateSelection(upTo: position)
                    }
                }
                .onEnded { _ in
                    guard !showVictory, !showMenu else { return }
                    confirmSelection()
                }
        )
    }

    private func highlightStrip(positions: [GridPosition], cellSize: CGFloat, color: Color, opacity: Double) -> some View {
        let thickness = cellSize * 0.72
        let endCap = cellSize * 0.82

        return Group {
            if positions.count == 1, let position = positions.first {
                Capsule()
                    .fill(color.opacity(opacity))
                    .frame(width: endCap, height: endCap)
                    .position(center(of: position, cellSize: cellSize))
            } else if let geometry = stripGeometry(positions: positions, cellSize: cellSize, thickness: thickness) {
                Capsule()
                    .fill(color.opacity(opacity))
                    .frame(width: geometry.length, height: thickness)
                    .rotationEffect(geometry.angle)
                    .position(geometry.center)
            }
        }
    }

    private func center(of position: GridPosition, cellSize: CGFloat) -> CGPoint {
        CGPoint(
            x: CGFloat(position.col) * (cellSize + spacing) + cellSize / 2,
            y: CGFloat(position.row) * (cellSize + spacing) + cellSize / 2
        )
    }

    private func stripGeometry(
        positions: [GridPosition],
        cellSize: CGFloat,
        thickness: CGFloat
    ) -> (center: CGPoint, length: CGFloat, angle: Angle)? {
        guard let first = positions.first, let last = positions.last else { return nil }

        let start = center(of: first, cellSize: cellSize)
        let end = center(of: last, cellSize: cellSize)
        let dx = end.x - start.x
        let dy = end.y - start.y
        let distance = hypot(dx, dy)
        let length = max(thickness, distance + cellSize * 0.92)
        let angle = Angle(radians: atan2(dy, dx))

        return (
            center: CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2),
            length: length,
            angle: angle
        )
    }

    private var wordList: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center)
            ],
            spacing: 12
        ) {
            ForEach(puzzle.words, id: \.self) { word in
                Text(word)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .strikethrough(foundWords.contains(word), color: accentColor)
                    .opacity(foundWords.contains(word) ? 0.55 : 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var bottomBar: some View {
        HStack(spacing: 16) {
            circularButton(color: accentColor, icon: "arrow.clockwise") {
                restartGame(playSound: true)
            }
            circularButton(color: .yellow, icon: "star.fill") {
                revealFirstLetter()
            }
            circularButton(color: .green, icon: "lightbulb.fill") {
                revealHint()
            }
            circularButton(
                color: soundEnabled ? .blue : .gray,
                icon: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"
            ) {
                soundEnabled.toggle()
                GameSounds.shared.isEnabled = soundEnabled
            }
            circularButton(color: .blue, icon: "line.3.horizontal") {
                openMenu()
            }
        }
        .padding(.vertical, 16)
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

    private func gridPosition(at point: CGPoint, cellSize: CGFloat, rows: Int, columns: Int) -> GridPosition? {
        let col = Int(point.x / (cellSize + spacing))
        let row = Int(point.y / (cellSize + spacing))
        guard row >= 0, row < rows, col >= 0, col < columns else { return nil }
        return GridPosition(row: row, col: col)
    }

    private func updateSelection(upTo position: GridPosition) {
        let previousCount = selection.count

        guard let first = selection.first else {
            selection = [position]
            if selection.count > previousCount {
                GameSounds.shared.playTap()
            }
            return
        }

        if selection.contains(position) {
            if selection.count > 1, selection[selection.count - 2] == position {
                selection.removeLast()
            }
            return
        }

        let deltaRow = position.row - first.row
        let deltaCol = position.col - first.col
        guard deltaRow != 0 || deltaCol != 0 else {
            selection = [position]
            return
        }

        let steps = max(abs(deltaRow), abs(deltaCol))
        let stepRow = deltaRow / steps
        let stepCol = deltaCol / steps
        guard abs(stepRow) <= 1, abs(stepCol) <= 1 else { return }

        var line: [GridPosition] = []
        for step in 0...steps {
            line.append(GridPosition(row: first.row + stepRow * step, col: first.col + stepCol * step))
        }
        selection = line

        if selection.count > previousCount {
            GameSounds.shared.playTap()
        }
    }

    private func confirmSelection() {
        let attempt = selection
        defer { selection = [] }

        guard attempt.count >= 2 else { return }

        if let word = WordSearchGenerator.word(in: attempt, puzzle: puzzle),
           !foundWords.contains(word) {
            markFound(word)
            return
        }

        GameSounds.shared.playFailure()
    }

    private func markFound(_ word: String) {
        foundWords.insert(word)
        if let firstCell = puzzle.placements.first(where: { $0.word == word })?.cells.first {
            firstLetterHints.remove(firstCell)
        }
        GameSounds.shared.playSuccess()
        checkVictory()
    }

    private func checkVictory() {
        guard foundWords.count == puzzle.words.count else { return }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            showVictory = true
        }
        showConfetti = true
        GameSounds.shared.playVictory()
    }

    private func openMenu() {
        showMenu = true
        showVictory = false
        showConfetti = false
        selection = []
        foundWords = []
        firstLetterHints = []
    }

    private func selectMode(_ mode: GameMode) {
        currentMode = mode
        showMenu = false
        if mode.isWordSearch {
            restartGame(playSound: true)
        } else {
            GameSounds.shared.playStart()
        }
    }

    private func restartGame(playSound: Bool) {
        guard let theme = currentMode?.wordSearchTheme else { return }

        puzzle = WordSearchGenerator.newGame(rows: layout.rows, theme: theme)
        selection = []
        foundWords = []
        firstLetterHints = []
        showConfetti = false
        showVictory = false

        if playSound {
            GameSounds.shared.playStart()
        }
    }

    private func updateLayout(width: CGFloat, height: CGFloat) {
        let updated = GridLayoutCalculator.calculate(width: width, availableHeight: height)
        let rowsChanged = layoutReady && updated.rows != puzzle.rows
        layout = updated

        if !layoutReady {
            layoutReady = true
            if currentMode?.isWordSearch == true {
                restartGame(playSound: false)
            }
        } else if rowsChanged, currentMode?.isWordSearch == true {
            restartGame(playSound: false)
        }
    }

    private func revealFirstLetter() {
        guard !showVictory, !showMenu else { return }

        let pending = puzzle.words.filter { !foundWords.contains($0) }
        guard !pending.isEmpty else { return }

        let word = pending.first { candidate in
            guard let firstCell = puzzle.placements.first(where: { $0.word == candidate })?.cells.first else {
                return false
            }
            return !firstLetterHints.contains(firstCell)
        } ?? pending[0]

        guard let firstCell = puzzle.placements.first(where: { $0.word == word })?.cells.first else { return }
        firstLetterHints.insert(firstCell)
    }

    private func revealHint() {
        guard let pending = puzzle.words.first(where: { !foundWords.contains($0) }) else { return }
        markFound(pending)
    }
}

#Preview {
    ContentView()
}
