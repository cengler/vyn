import SwiftUI
import UIKit

struct CraftIconView: View {
    let id: String
    var size: CGFloat = 52

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .padding(size * 0.08)
            } else {
                fallback
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
        .task(id: id) {
            image = CraftIconLoader.image(named: id)
        }
    }

    private var fallback: some View {
        let rgb = CraftIconPalette.color(for: id)
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: rgb.red, green: rgb.green, blue: rgb.blue))
            Text(String(id.prefix(2)))
                .font(.system(size: size * 0.28, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

enum CraftIconLoader {
    private static let cache = NSCache<NSString, UIImage>()
    private static var missing = Set<String>()
    private static let iconsFolder = "CraftingIcons"
    private static let urlIndex: [String: URL] = buildURLIndex()
    private static let loadLock = NSLock()

    static func image(named id: String) -> UIImage? {
        if missing.contains(id) {
            return nil
        }

        let key = id as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        loadLock.lock()
        defer { loadLock.unlock() }

        if missing.contains(id) {
            return nil
        }
        if let cached = cache.object(forKey: key) {
            return cached
        }

        guard let url = urlIndex[id],
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            missing.insert(id)
            return nil
        }

        cache.setObject(image, forKey: key)
        return image
    }

    static func preload(ids: [String]) {
        for id in Set(ids) {
            _ = image(named: id)
        }
    }

    private static func buildURLIndex() -> [String: URL] {
        var index: [String: URL] = [:]

        if let folderURL = Bundle.main.url(forResource: iconsFolder, withExtension: nil) {
            addURLs(from: folderURL, to: &index)
        }

        if let resourceURL = Bundle.main.resourceURL {
            let folderURL = resourceURL.appendingPathComponent(iconsFolder, isDirectory: true)
            addURLs(from: folderURL, to: &index)
        }

        return index
    }

    private static func addURLs(from folderURL: URL, to index: inout [String: URL]) {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil
        ) else {
            return
        }

        for url in files where url.pathExtension.lowercased() == "png" {
            index[url.deletingPathExtension().lastPathComponent] = url
        }
    }
}
