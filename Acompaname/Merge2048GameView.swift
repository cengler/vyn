import SwiftUI

struct Merge2048GameView: View {
    let onMenu: () -> Void

    @State private var state = Merge2048State.newGame()
    @State private var showConfetti = false
    @State private var showVictory = false
    @State private var showGameOver = false
    @State private var mergedTileIDs: Set<UUID> = []
    @State private var spawnedTileID: UUID?
    @State private var flashOpacity: Double = 0

    private let backgroundColor = Color(red: 0.08, green: 0.14, blue: 0.28)
    private let slotColor = Color(red: 0.12, green: 0.20, blue: 0.36)
    private let accentColor = Color(red: 0.95, green: 0.35, blue: 0.55)

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                statsBar
                board
                evolutionLegend
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
                overlay(message: victoryOverlay) { onMenu() }
            } else if showGameOver {
                overlay(message: gameOverOverlay) { restartGame() }
            }
        }
        .onAppear(perform: restartGame)
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
            HStack {
                Text(L10n.mergeScore(state.score))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                if let best = highestTier {
                    Text(best.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Text(L10n.mergeInstruction)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var highestTier: MergeTier? {
        let maxValue = state.tiles.values.map(\.value).max() ?? 0
        return MergeTier(rawValue: maxValue)
    }

    private var board: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 8
            let gridSize = Merge2048State.size
            let tileSize = min(
                (geo.size.width - spacing * CGFloat(gridSize - 1) - 32) / CGFloat(gridSize),
                (geo.size.height - spacing * CGFloat(gridSize - 1) - 16) / CGFloat(gridSize)
            )
            let boardWidth = tileSize * CGFloat(gridSize) + spacing * CGFloat(gridSize - 1)
            let boardHeight = boardWidth

            ZStack(alignment: .topLeading) {
                VStack(spacing: spacing) {
                    ForEach(0..<gridSize, id: \.self) { _ in
                        HStack(spacing: spacing) {
                            ForEach(0..<gridSize, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(slotColor.opacity(0.55))
                                    .frame(width: tileSize, height: tileSize)
                            }
                        }
                    }
                }

                ForEach(state.activeTiles) { tile in
                    if let position = state.position(of: tile.id) {
                        materialTile(
                            tile: tile,
                            size: tileSize,
                            isMerged: mergedTileIDs.contains(tile.id),
                            isSpawned: spawnedTileID == tile.id
                        )
                        .frame(width: tileSize, height: tileSize)
                        .offset(
                            x: CGFloat(position.col) * (tileSize + spacing),
                            y: CGFloat(position.row) * (tileSize + spacing)
                        )
                        .animation(.spring(response: 0.24, dampingFraction: 0.78), value: position.row)
                        .animation(.spring(response: 0.24, dampingFraction: 0.78), value: position.col)
                        .animation(.spring(response: 0.24, dampingFraction: 0.78), value: tile.value)
                    }
                }
            }
            .frame(width: boardWidth, height: boardHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(boardDragGesture)
    }

    private func materialTile(tile: Merge2048Tile, size: CGFloat, isMerged: Bool, isSpawned: Bool) -> some View {
        let tier = MergeTier(rawValue: tile.value)

        return ZStack {
            if let tier {
                CraftIconView(
                    id: tier.iconID,
                    size: size,
                    contentPadding: 0,
                    cornerRadius: 12,
                    showsBorder: false
                )
            }

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(flashOpacity))
                .opacity(isMerged ? 1 : 0)

            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(isMerged ? 0.95 : 0), lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .scaleEffect(isMerged ? 1.08 : (isSpawned ? 0.82 : 1))
        .animation(.spring(response: 0.18, dampingFraction: 0.62), value: isMerged)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isSpawned)
    }

    private var evolutionLegend: some View {
        HStack(spacing: 6) {
            ForEach(Array(MergeTier.allCases.enumerated()), id: \.element.rawValue) { index, tier in
                CraftIconView(id: tier.iconID, size: 32, contentPadding: 0, cornerRadius: 6, showsBorder: false)

                if index < MergeTier.allCases.count - 1 {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            circularButton(color: accentColor, icon: "arrow.clockwise") {
                restartGame()
                GameSounds.shared.playStart()
            }
            circularButton(color: .blue, icon: "line.3.horizontal") {
                onMenu()
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.05, green: 0.09, blue: 0.18))
    }

    private var victoryOverlay: some View {
        VStack(spacing: 10) {
            CraftIconView(id: MergeTier.netherite.iconID, size: 72, contentPadding: 0, cornerRadius: 12, showsBorder: false)
            Text(L10n.mergeVictoryTitle)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.mergeVictorySubtitle)
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Text(L10n.mergeVictoryAction)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .background(overlayBackground)
    }

    private var gameOverOverlay: some View {
        VStack(spacing: 10) {
            Text(L10n.mergeGameOverTitle)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.mergeScore(state.score))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Text(L10n.mergeGameOverAction)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .background(overlayBackground)
    }

    private var overlayBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(accentColor, lineWidth: 2)
            )
    }

    private func overlay(message: some View, action: @escaping () -> Void) -> some View {
        ZStack {
            Color.black.opacity(0.52)
                .ignoresSafeArea()

            Button(action: action) {
                message
            }
            .buttonStyle(.plain)
        }
    }

    private var boardDragGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height

                guard abs(horizontal) > abs(vertical) else {
                    performMove(vertical < 0 ? .up : .down)
                    return
                }
                performMove(horizontal < 0 ? .left : .right)
            }
    }

    private func performMove(_ direction: Merge2048Direction) {
        guard !showVictory, !showGameOver else { return }

        let outcome = state.move(direction)
        guard outcome.moved else { return }

        mergedTileIDs = outcome.mergedTileIDs
        spawnedTileID = outcome.spawnedTileID

        if !outcome.mergedTileIDs.isEmpty {
            GameSounds.shared.playSuccess()
            triggerMergeFlash()
        } else {
            GameSounds.shared.playTap()
        }

        if outcome.spawnedTileID != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                spawnedTileID = nil
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            mergedTileIDs = []
        }

        if state.hasWon, !showVictory {
            showConfetti = true
            GameSounds.shared.playVictory()
            withAnimation {
                showVictory = true
            }
        } else if state.isGameOver {
            GameSounds.shared.playFailure()
            withAnimation {
                showGameOver = true
            }
        }
    }

    private func triggerMergeFlash() {
        flashOpacity = 0.85
        withAnimation(.easeOut(duration: 0.18)) {
            flashOpacity = 0
        }
    }

    private func restartGame() {
        state = Merge2048State.newGame()
        mergedTileIDs = []
        spawnedTileID = nil
        flashOpacity = 0
        showConfetti = false
        showVictory = false
        showGameOver = false
        CraftIconLoader.preload(ids: MergeTier.allCases.map(\.iconID))
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
}
