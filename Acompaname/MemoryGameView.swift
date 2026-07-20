import SwiftUI

struct MemoryGameView: View {
    let onMenu: () -> Void

    @State private var cards: [MemoryCard] = []
    @State private var selectedIDs: [UUID] = []
    @State private var moves = 0
    @State private var lockInput = false
    @State private var showConfetti = false
    @State private var showVictory = false

    private let backgroundColor = Color(red: 0.08, green: 0.14, blue: 0.28)
    private let accentColor = Color(red: 0.95, green: 0.35, blue: 0.55)

    private var matchedPairs: Int {
        cards.filter(\.isMatched).count / 2
    }

    private var totalPairs: Int {
        MemoryGameEngine.pairCount
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                statsBar
                board
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
        .onAppear(perform: startNewGame)
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
                Text(L10n.memoryPairsProgress(matched: matchedPairs, total: totalPairs))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text(L10n.memoryMoves(moves))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text(L10n.memoryInstruction)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var board: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 10
            let columns = MemoryGameEngine.columns
            let cardSize = min(
                (geo.size.width - spacing * CGFloat(columns - 1) - 32) / CGFloat(columns),
                (geo.size.height - spacing * 3) / 4
            )

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
                spacing: spacing
            ) {
                ForEach(cards) { card in
                    memoryCardView(card, size: cardSize)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private func memoryCardView(_ card: MemoryCard, size: CGFloat) -> some View {
        let isRevealed = card.isFaceUp || card.isMatched

        Button {
            flip(card)
        } label: {
            ZStack {
                cardBackView(size: size)
                    .opacity(isRevealed ? 0 : 1)

                RoundedRectangle(cornerRadius: 12)
                    .fill(accentColor.opacity(0.35))
                    .opacity(isRevealed && card.isMatched ? 1 : 0)

                if isRevealed {
                    CraftIconView(
                        id: card.itemID,
                        size: size,
                        contentPadding: 0,
                        cornerRadius: 12,
                        showsBorder: false
                    )
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(card.isMatched ? accentColor : .white.opacity(isRevealed ? 0.15 : 0.2), lineWidth: card.isMatched ? 2 : 1)
            )
            .rotation3DEffect(.degrees(isRevealed ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: card.isFaceUp)
            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: card.isMatched)
        }
        .buttonStyle(.plain)
        .disabled(lockInput || card.isMatched || card.isFaceUp)
    }

    private func cardBackView(size: CGFloat) -> some View {
        Image("MemoryCardBack")
            .resizable()
            .interpolation(.none)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipped()
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            circularButton(color: accentColor, icon: "arrow.clockwise") {
                startNewGame()
                GameSounds.shared.playStart()
            }
            circularButton(color: .yellow, icon: "star.fill") {
                flashHint()
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
            Text(L10n.memoryVictoryTitle)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.memoryVictorySubtitle(moves: moves))
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Text(L10n.memoryVictoryAction)
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

    private func startNewGame() {
        cards = MemoryGameEngine.newGame()
        selectedIDs = []
        moves = 0
        lockInput = false
        showVictory = false
        showConfetti = false
        CraftIconLoader.preload(ids: cards.map(\.itemID))
    }

    private func flip(_ card: MemoryCard) {
        guard !lockInput,
              !card.isMatched,
              !card.isFaceUp,
              let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        cards[index].isFaceUp = true
        selectedIDs.append(card.id)
        GameSounds.shared.playTap()

        guard selectedIDs.count == 2 else { return }

        moves += 1
        lockInput = true

        let firstIndex = cards.firstIndex { $0.id == selectedIDs[0] }
        let secondIndex = cards.firstIndex { $0.id == selectedIDs[1] }
        guard let firstIndex, let secondIndex else {
            resetSelection()
            return
        }

        if cards[firstIndex].itemID == cards[secondIndex].itemID {
            cards[firstIndex].isMatched = true
            cards[secondIndex].isMatched = true
            GameSounds.shared.playSuccess()
            resetSelection()
            checkVictory()
        } else {
            GameSounds.shared.playFailure()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                cards[firstIndex].isFaceUp = false
                cards[secondIndex].isFaceUp = false
                resetSelection()
            }
        }
    }

    private func resetSelection() {
        selectedIDs = []
        lockInput = false
    }

    private func checkVictory() {
        guard cards.allSatisfy(\.isMatched) else { return }

        showConfetti = true
        GameSounds.shared.playVictory()
        withAnimation {
            showVictory = true
        }
    }

    private func flashHint() {
        guard !showVictory, !lockInput else { return }

        guard let itemID = cards.first(where: { !$0.isMatched })?.itemID,
              let first = cards.firstIndex(where: { $0.itemID == itemID && !$0.isMatched }),
              let second = cards.lastIndex(where: { $0.itemID == itemID && !$0.isMatched && $0.id != cards[first].id })
        else { return }

        lockInput = true
        cards[first].isFaceUp = true
        cards[second].isFaceUp = true
        GameSounds.shared.playTap()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if !cards[first].isMatched { cards[first].isFaceUp = false }
            if !cards[second].isMatched { cards[second].isFaceUp = false }
            lockInput = false
        }
    }
}
