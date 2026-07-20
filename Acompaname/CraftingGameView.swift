import SwiftUI

struct CraftingGameView: View {
    let onMenu: () -> Void

    @State private var sessionRecipes: [CraftRecipe] = []
    @State private var currentIndex = 0
    @State private var grid: [[String?]] = CraftingGameView.emptyGrid
    @State private var selectedMaterial: String?
    @State private var materialOptions: [String] = []
    @State private var showConfetti = false
    @State private var showVictory = false
    @State private var showError = false
    @State private var showRecipeHint = false
    @State private var gridBeforeHint: [[String?]]?
    @State private var loadState: LoadState = .loading
    @State private var loadTask: Task<Void, Never>?

    private enum LoadState {
        case loading
        case ready
        case unavailable
    }

    private let backgroundColor = Color(red: 0.08, green: 0.14, blue: 0.28)
    private let cellColor = Color(red: 0.12, green: 0.20, blue: 0.36)
    private let accentColor = Color(red: 0.95, green: 0.35, blue: 0.55)
    private let tableColor = Color(red: 0.55, green: 0.38, blue: 0.24)

    private var currentRecipe: CraftRecipe? {
        guard currentIndex >= 0, currentIndex < sessionRecipes.count else { return nil }
        return sessionRecipes[currentIndex]
    }

    private var sessionCount: Int {
        sessionRecipes.count
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header

                switch loadState {
                case .loading:
                    Spacer()
                    ProgressView(L10n.craftingLoading)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .tint(.white)
                    Spacer()
                    actionBar

                case .unavailable:
                    Spacer()
                    missingRecipesView
                    Spacer()
                    actionBar

                case .ready:
                    if let _ = currentRecipe {
                        Spacer(minLength: 8)
                        targetView
                        Spacer(minLength: 12)
                        craftingTable
                        Spacer(minLength: 16)
                        materialPicker
                        Spacer(minLength: 8)
                        actionBar
                    } else {
                        Spacer()
                        missingRecipesView
                        Spacer()
                        actionBar
                    }
                }

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
        .onAppear(perform: beginLoadingSession)
        .onDisappear {
            loadTask?.cancel()
        }
    }

    private var header: some View {
        HStack {
            Text(L10n.appTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .italic()
                .foregroundStyle(.white)
            Spacer()
            if loadState == .ready, sessionCount > 0 {
                Text("\(min(currentIndex + 1, sessionCount))/\(sessionCount)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color(red: 0.06, green: 0.11, blue: 0.22))
    }

    private var missingRecipesView: some View {
        VStack(spacing: 12) {
            Text(L10n.craftingUnavailable)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            if let issue = CraftingCatalog.loadIssue {
                Text(issue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
    }

    @ViewBuilder
    private var targetView: some View {
        if let recipe = currentRecipe {
            VStack(spacing: 10) {
                Text(L10n.craftingAction)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))

                CraftIconView(id: recipe.result, size: 72)

                Text(recipe.displayName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(L10n.craftingInstruction)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
    }

    private var craftingTable: some View {
        VStack(spacing: 10) {
            Text(L10n.craftingTable)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(tableColor.opacity(0.95))
                    .frame(width: 280, height: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 2)
                    )

                VStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { col in
                                craftingCell(row: row, col: col)
                            }
                        }
                    }
                }
            }
        }
    }

    private func craftingCell(row: Int, col: Int) -> some View {
        Button {
            placeMaterial(row: row, col: col)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(cellColor)
                    .frame(width: 78, height: 78)

                if let material = grid[row][col] {
                    CraftIconView(id: material, size: 58)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(showRecipeHint || showVictory)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                guard !showRecipeHint else { return }
                grid[row][col] = nil
            }
        )
    }

    private var materialPicker: some View {
        VStack(spacing: 10) {
            Text(L10n.craftingPickMaterial)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(materialOptions, id: \.self) { material in
                    Button {
                        selectedMaterial = material
                        GameSounds.shared.playTap()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMaterial == material ? accentColor.opacity(0.55) : cellColor)
                                .frame(height: 72)
                            CraftIconView(id: material, size: 52)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            circularButton(color: accentColor, icon: "arrow.clockwise") {
                beginLoadingSession()
                GameSounds.shared.playStart()
            }
            circularButton(color: .yellow, icon: "star.fill") {
                flashRecipeHint()
            }
            .disabled(loadState != .ready)
            circularButton(color: .orange, icon: "trash.fill") {
                clearGrid()
            }
            .disabled(loadState != .ready)
            circularButton(color: .green, icon: "checkmark") {
                verifyCraft()
            }
            .disabled(loadState != .ready)
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
            Text(L10n.craftingVictoryTitle)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.craftingVictorySubtitle(count: sessionCount))
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Text(L10n.craftingVictoryAction)
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

    private func beginLoadingSession() {
        loadTask?.cancel()
        loadState = .loading
        showVictory = false
        showConfetti = false

        loadTask = Task { @MainActor in
            let recipes = CraftingCatalog.randomSession()
            guard !Task.isCancelled else { return }

            guard !recipes.isEmpty else {
                sessionRecipes = []
                loadState = .unavailable
                return
            }

            let iconIDs = recipes.reduce(into: Set<String>()) { ids, recipe in
                ids.formUnion(recipe.requiredMaterials)
                ids.insert(recipe.result)
            }

            await Task.detached(priority: .userInitiated) {
                CraftIconLoader.preload(ids: Array(iconIDs))
            }.value

            guard !Task.isCancelled else { return }

            sessionRecipes = recipes
            currentIndex = 0
            prepareRecipe()
            loadState = .ready
        }
    }

    private func prepareRecipe() {
        guard let recipe = currentRecipe else {
            grid = Self.emptyGrid
            materialOptions = []
            selectedMaterial = nil
            return
        }

        gridBeforeHint = nil
        showRecipeHint = false
        grid = Self.emptyGrid
        selectedMaterial = nil
        showError = false
        showConfetti = false
        showVictory = false
        materialOptions = recipe.materialOptions()
        CraftIconLoader.preload(ids: materialOptions + [recipe.result])
    }

    private func placeMaterial(row: Int, col: Int) {
        guard let material = selectedMaterial else { return }
        grid[row][col] = material
        GameSounds.shared.playTap()
    }

    private func clearGrid() {
        grid = Self.emptyGrid
    }

    private func flashRecipeHint() {
        guard !showRecipeHint, !showVictory, let recipe = currentRecipe else { return }

        gridBeforeHint = grid.map { row in Array(row) }
        grid = recipe.pattern
        showRecipeHint = true
        GameSounds.shared.playTap()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let previous = gridBeforeHint {
                grid = previous
            }
            gridBeforeHint = nil
            showRecipeHint = false
        }
    }

    private static let emptyGrid: [[String?]] = [
        [nil, nil, nil],
        [nil, nil, nil],
        [nil, nil, nil]
    ]

    private func verifyCraft() {
        guard !showRecipeHint, let recipe = currentRecipe else { return }

        let isCorrect = (0..<3).allSatisfy { row in
            (0..<3).allSatisfy { col in
                grid[row][col] == recipe.pattern[row][col]
            }
        }

        if isCorrect {
            GameSounds.shared.playSuccess()
            if currentIndex >= sessionCount - 1 {
                showConfetti = true
                GameSounds.shared.playVictory()
                withAnimation {
                    showVictory = true
                }
            } else {
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showConfetti = false
                }
                currentIndex += 1
                prepareRecipe()
            }
        } else {
            GameSounds.shared.playFailure()
            withAnimation(.default) {
                showError = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showError = false
            }
        }
    }
}
