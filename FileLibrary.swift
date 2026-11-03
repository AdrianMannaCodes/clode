import Foundation
import Combine

/// Manages files stored in the app's Documents folder. No iCloud dependency.
@MainActor
final class FileLibrary: ObservableObject {
    @Published private(set) var files: [FileItem] = []
    @Published var lastError: String?

    private let fm = FileManager.default

    var libraryURL: URL {
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("WheelClodeLibrary", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    init() {
        reload()
    }

    func reload() {
        let urls = (try? fm.contentsOfDirectory(at: libraryURL,
                                                includingPropertiesForKeys: nil,
                                                options: [.skipsHiddenFiles])) ?? []
        files = urls.map { FileItem(url: $0) }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func files(in category: FileCategory) -> [FileItem] {
        files.filter { $0.kind.category == category }
    }

    /// Copies an external file (from the Files picker, a share, or a peer) into the library.
    @discardableResult
    func importFile(from source: URL) -> Bool {
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        var destination = libraryURL.appendingPathComponent(source.lastPathComponent)
        var counter = 1
        while fm.fileExists(atPath: destination.path) {
            let base = source.deletingPathExtension().lastPathComponent
            let ext = source.pathExtension
            destination = libraryURL.appendingPathComponent("\(base) (\(counter)).\(ext)")
            counter += 1
        }
        do {
            try fm.copyItem(at: source, to: destination)
            reload()
            return true
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func delete(_ item: FileItem) {
        do {
            try fm.removeItem(at: item.url)
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func rename(_ item: FileItem, to newName: String) {
        let target = libraryURL.appendingPathComponent(newName)
        do {
            try fm.moveItem(at: item.url, to: target)
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }
}
