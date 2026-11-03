import Foundation

/// Broad groups used for the iPod menus.
enum FileCategory: String, CaseIterable, Identifiable {
    case audio = "Audio"
    case video = "Video"
    case images = "Images"
    case text = "Text"
    case code = "Code"
    case documents = "Documents"
    case archives = "Archives"
    case data = "Data"
    case other = "Other"

    var id: String { rawValue }
}

/// 20+ supported file kinds.
enum FileKind: String, CaseIterable, Identifiable {
    // Audio
    case mp3, m4a, wav, aiff, flac, ogg
    // Video
    case mp4, mov, m4v, avi, mkv
    // Images
    case jpg, png, gif, heic, svg, webp
    // Text
    case txt, md, rtf, csv
    // Code
    case swift, js, py, html, css, json, xml
    // Documents
    case pdf, docx, pages, numbers, keynote
    // Archives
    case zip, gz, tar
    // Data
    case sqlite
    // Fallback
    case unknown

    var id: String { rawValue }

    var category: FileCategory {
        switch self {
        case .mp3, .m4a, .wav, .aiff, .flac, .ogg: return .audio
        case .mp4, .mov, .m4v, .avi, .mkv: return .video
        case .jpg, .png, .gif, .heic, .svg, .webp: return .images
        case .txt, .md, .rtf, .csv: return .text
        case .swift, .js, .py, .html, .css, .json, .xml: return .code
        case .pdf, .docx, .pages, .numbers, .keynote: return .documents
        case .zip, .gz, .tar: return .archives
        case .sqlite: return .data
        case .unknown: return .other
        }
    }

    var displayName: String {
        self == .unknown ? "File" : rawValue.uppercased()
    }

    /// Maps a file extension to a kind.
    static func from(extension ext: String) -> FileKind {
        let lower = ext.lowercased()
        return FileKind.allCases.first { $0 != .unknown && $0.rawValue == lower } ?? .unknown
    }

    var systemImage: String {
        switch category {
        case .audio: return "music.note"
        case .video: return "film"
        case .images: return "photo"
        case .text: return "doc.plaintext"
        case .code: return "chevron.left.slash.chevron.right"
        case .documents: return "doc.richtext"
        case .archives: return "archivebox"
        case .data: return "cylinder"
        case .other: return "doc"
        }
    }
}

/// A file managed by the app.
struct FileItem: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let name: String
    let kind: FileKind
    let size: Int64
    let modified: Date

    init(url: URL, id: UUID = UUID()) {
        self.id = id
        self.url = url
        self.name = url.lastPathComponent
        self.kind = FileKind.from(extension: url.pathExtension)
        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
        self.size = Int64(values?.fileSize ?? 0)
        self.modified = values?.contentModificationDate ?? Date()
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
