import SwiftUI

enum IPodScreen: Hashable {
    case menu
    case category(FileCategory)
    case collaboration
    case about
}

struct ContentView: View {
    @EnvironmentObject var library: FileLibrary
    @EnvironmentObject var collaboration: CollaborationManager

    @State private var path: [IPodScreen] = []
    @State private var selectedIndex = 0
    @State private var showImporter = false

    private var rootItems: [(title: String, screen: IPodScreen)] {
        FileCategory.allCases.map { ($0.rawValue, IPodScreen.category($0)) } + [
            ("Collaborate", .collaboration),
            ("About", .about)
        ]
    }

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94).ignoresSafeArea()
            VStack(spacing: 24) {
                screenView
                    .frame(maxWidth: 320, maxHeight: 380)
                    .background(Color(red: 0.75, green: 0.9, blue: 0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.4), lineWidth: 6))

                iPodWheelView(
                    onScroll: { step in
                        selectedIndex = max(0, min(rootItems.count - 1, selectedIndex + step))
                    },
                    onMenu: { if !path.isEmpty { path.removeLast() } },
                    onPlayPause: { showImporter = true },
                    onNext: { },
                    onPrevious: { },
                    onSelect: { if path.isEmpty { path.append(rootItems[selectedIndex].screen) } }
                )
                .frame(maxWidth: 300)
            }
            .padding()
        }
        .fileImporter(isPresented: $showImporter,
                      allowedContentTypes: [.item],
                      allowsMultipleSelection: true) { result in
            if case .success(let urls) = result {
                urls.forEach { library.importFile(from: $0) }
            }
        }
    }

    @ViewBuilder
    private var screenView: some View {
        if let current = path.last {
            switch current {
            case .category(let cat):
                FileListView(category: cat)
            case .collaboration:
                CollaborationView()
            case .about:
                AboutView()
            case .menu:
                EmptyView()
            }
        } else {
            List {
                ForEach(Array(rootItems.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(index == selectedIndex ? Color.blue.opacity(0.35) : Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedIndex = index; path.append(item.screen) }
                }
            }
            .listStyle(.plain)
            .navigationTitle("WheelClode")
        }
    }
}

struct FileListView: View {
    @EnvironmentObject var library: FileLibrary
    let category: FileCategory

    var body: some View {
        let items = library.files(in: category)
        List {
            if items.isEmpty {
                Text("No \(category.rawValue.lowercased()) files")
                    .foregroundStyle(.secondary)
            }
            ForEach(items) { item in
                NavigationLink(value: item) {
                    Label {
                        VStack(alignment: .leading) {
                            Text(item.name).lineLimit(1)
                            Text("\(item.kind.displayName) • \(item.formattedSize)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: item.kind.systemImage)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) { library.delete(item) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(category.rawValue)
        .navigationDestination(for: FileItem.self) { item in
            FileDetailView(item: item)
        }
    }
}

struct FileDetailView: View {
    let item: FileItem
    @State private var showShare = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: item.kind.systemImage).font(.system(size: 64))
            Text(item.name).font(.headline)
            Text("\(item.kind.displayName) • \(item.formattedSize)")
            Text("Modified \(item.modified.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption).foregroundStyle(.secondary)
            Button {
                showShare = true
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [item.url])
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("WheelClode iPod").font(.headline)
            Text("Files: local Documents only")
            Text("Sharing: MultipeerConnectivity (Wi-Fi / Bluetooth)")
            Text("Supports \(FileKind.allCases.count - 1) file types")
        }
        .font(.footnote)
        .padding()
    }
}
