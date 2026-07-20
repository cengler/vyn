import SwiftUI

struct TabooGameView: View {
    let onMenu: () -> Void

    @State private var deck: [TabooCard] = []
    @State private var currentIndex = 0
    @State private var successCount = 0
    @State private var failureCount = 0

    private let backgroundColor = Color(red: 0.08, green: 0.14, blue: 0.28)
    private let cellColor = Color(red: 0.12, green: 0.20, blue: 0.36)
    private let accentColor = Color(red: 0.95, green: 0.35, blue: 0.55)

    private var currentCard: TabooCard {
        guard !deck.isEmpty, currentIndex >= 0, currentIndex < deck.count else {
            return TabooCard(id: "empty", word: "—", forbidden: ["—", "—", "—", "—"])
        }
        return deck[currentIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            scoreBar
            cardContent
            resultButtons
            actionBar
            Text(L10n.craftingAttribution)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.35))
                .padding(.bottom, 6)
        }
        .background(backgroundColor.ignoresSafeArea())
        .onAppear(perform: restartSession)
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

    private var scoreBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                scoreBadge(
                    title: L10n.tabooSuccessLabel,
                    value: successCount,
                    color: .green
                )
                scoreBadge(
                    title: L10n.tabooFailureLabel,
                    value: failureCount,
                    color: .red
                )
            }

            Text(L10n.tabooInstruction)
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

    private var cardContent: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 8)

            Text(currentCard.word)
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(L10n.tabooForbiddenTitle)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(accentColor)

            VStack(spacing: 10) {
                ForEach(currentCard.forbidden, id: \.self) { word in
                    Text(word)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(cellColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(.white.opacity(0.12), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 8)
        }
        .frame(maxHeight: .infinity)
    }

    private var resultButtons: some View {
        HStack(spacing: 14) {
            Button(action: recordFailure) {
                Label(L10n.tabooFailure, systemImage: "xmark")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.opacity(0.85))
                    )
            }
            .buttonStyle(.plain)

            Button(action: recordSuccess) {
                Label(L10n.tabooSuccess, systemImage: "checkmark")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.85))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            circularButton(color: accentColor, icon: "arrow.clockwise") {
                restartSession()
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

    private func restartSession() {
        deck = TabooDeck.shuffledDeck()
        currentIndex = 0
        successCount = 0
        failureCount = 0
    }

    private func recordSuccess() {
        successCount += 1
        GameSounds.shared.playSuccess()
        advanceCard()
    }

    private func recordFailure() {
        failureCount += 1
        GameSounds.shared.playFailure()
        advanceCard()
    }

    private func advanceCard() {
        guard !deck.isEmpty else { return }
        let next = TabooSession.nextCard(after: currentIndex, in: deck)
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex = next.index
        }
    }
}
