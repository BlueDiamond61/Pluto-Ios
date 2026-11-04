import SwiftUI
import UniformTypeIdentifiers

private enum NovaTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case library = "Library"
    case editor = "Editor"
    case files = "Files"
    case settings = "Settings"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: return "square.grid.2x2.fill"
        case .library: return "square.stack.3d.up.fill"
        case .editor: return "chevron.left.forwardslash.chevron.right"
        case .files: return "folder.fill"
        case .settings: return "slider.horizontal.3"
        }
    }
}

private struct NovaScript: Identifiable {
    let id: UUID
    var name: String
    var source: String
    var updated: Date

    init(name: String, source: String, updated: Date = .now) {
        self.id = UUID()
        self.name = name
        self.source = source
        self.updated = updated
    }
}

private enum NovaPalette {
    static let background = Color(red: 0.035, green: 0.027, blue: 0.060)
    static let surface = Color(red: 0.085, green: 0.065, blue: 0.125)
    static let elevated = Color(red: 0.125, green: 0.090, blue: 0.185)
    static let purple = Color(red: 0.60, green: 0.36, blue: 0.98)
    static let lavender = Color(red: 0.72, green: 0.61, blue: 1.0)
    static let muted = Color.white.opacity(0.48)
}

struct ContentView: View {
    @State private var selectedTab: NovaTab = .home
    @State private var scripts: [NovaScript] = [
        NovaScript(name: "Hello World", source: "local message = \"Hello, Nova!\"\nprint(message)"),
        NovaScript(name: "Table Basics", source: "local colors = {\n    \"violet\",\n    \"indigo\",\n    \"blue\"\n}\n\nfor index, color in ipairs(colors) do\n    print(index, color)\nend")
    ]
    @State private var selectedScriptID: UUID?
    @State private var editorText = "-- Welcome to Nova\n\nlocal message = \"Your workspace is ready.\"\nprint(message)"
    @State private var editorName = "Untitled.lua"
    @State private var searchText = ""
    @State private var showingImporter = false
    @State private var showingNewScript = false
    @State private var newScriptName = ""
    @State private var notice: String?
    @State private var showInspector = false

    private var selectedScript: NovaScript? {
        scripts.first { $0.id == selectedScriptID }
    }

    private var filteredScripts: [NovaScript] {
        guard !searchText.isEmpty else { return scripts }
        return scripts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.source.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            NovaPalette.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Group {
                    switch selectedTab {
                    case .home: homeView
                    case .library: libraryView
                    case .editor: editorView
                    case .files: filesView
                    case .settings: settingsView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }
        }
        .preferredColorScheme(.dark)
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.plainText, .sourceCode],
            allowsMultipleSelection: false
        ) { result in
            importSource(result)
        }
        .alert("Create a script", isPresented: $showingNewScript) {
            TextField("File name", text: $newScriptName)
            Button("Create") { createScript() }
            Button("Cancel", role: .cancel) { newScriptName = "" }
        } message: {
            Text("Create a local Lua text file in your Nova library.")
        }
        .alert("Workspace", isPresented: Binding(
            get: { notice != nil },
            set: { if !$0 { notice = nil } }
        )) {
            Button("OK", role: .cancel) { notice = nil }
        } message: {
            Text(notice ?? "")
        }
        .sheet(isPresented: $showInspector) {
            inspectorSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(
                        colors: [NovaPalette.purple, Color(red: 0.30, green: 0.16, blue: 0.66)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 46, height: 46)

                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("NOVA")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .tracking(2.4)

                Text("SCRIPT WORKSPACE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(NovaPalette.muted)
            }

            Spacer()

            Button {
                selectedTab = .settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 42, height: 42)
                    .background(NovaPalette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
    }

    private var homeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 9) {
                    Text("YOUR CREATIVE SPACE")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(2.2)
                        .foregroundStyle(NovaPalette.lavender)

                    Text("Build something\nbrilliant.")
                        .font(.system(size: 35, weight: .black, design: .rounded))
                        .lineSpacing(-2)

                    Text("A clean, focused place to write, organize, and inspect your Lua projects.")
                        .font(.system(size: 14))
                        .foregroundStyle(NovaPalette.muted)
                        .lineSpacing(4)
                }
                .padding(.top, 12)

                HStack(spacing: 12) {
                    metricCard(title: "PROJECTS", value: "\(scripts.count)", icon: "doc.text.fill")
                    metricCard(title: "CURRENT FILE", value: editorName, icon: "chevron.left.forwardslash.chevron.right", compact: true)
                }

                Button {
                    newScriptName = ""
                    showingNewScript = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Text("New Lua file")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(17)
                    .background(LinearGradient(
                        colors: [NovaPalette.purple, Color(red: 0.36, green: 0.20, blue: 0.72)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .clipShape(RoundedRectangle(cornerRadius: 17))
                }

                sectionHeading("RECENT PROJECTS", trailing: "VIEW ALL") {
                    selectedTab = .library
                }

                ForEach(scripts.prefix(3)) { script in
                    scriptRow(script)
                }

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(NovaPalette.lavender)
                    Text("Nova is a local code workspace. It does not inject code into games, attach to other apps, or bypass platform protections.")
                        .font(.system(size: 11))
                        .foregroundStyle(NovaPalette.muted)
                        .lineSpacing(4)
                }
                .padding(15)
                .background(NovaPalette.surface)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(20)
        }
    }

    private var libraryView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 17) {
                pageTitle("Script Library", subtitle: "Your saved local projects")

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(NovaPalette.muted)
                    TextField("Search files", text: $searchText)
                        .font(.system(size: 14))
                }
                .padding(13)
                .background(NovaPalette.surface)
                .clipShape(RoundedRectangle(cornerRadius: 13))

                Button {
                    newScriptName = ""
                    showingNewScript = true
                } label: {
                    Label("Create project", systemImage: "plus.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(NovaPalette.lavender)
                }

                ForEach(filteredScripts) { script in
                    scriptRow(script)
                }

                if filteredScripts.isEmpty {
                    emptyState(icon: "doc.text.magnifyingglass", title: "No matching files", detail: "Try another search or create a new Lua file.")
                }
            }
            .padding(20)
        }
    }

    private var editorView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CODE EDITOR")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1.8)
                        .foregroundStyle(NovaPalette.lavender)

                    Text(editorName)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }

                Spacer()

                Button {
                    showInspector = true
                } label: {
                    Image(systemName: "text.magnifyingglass")
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 38, height: 38)
                        .background(NovaPalette.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                }

                Button {
                    saveCurrentScript()
                } label: {
                    Image(systemName: "square.and.arrow.down.fill")
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(NovaPalette.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                }
            }
            .padding(16)

            HStack(spacing: 7) {
                Circle().fill(Color(red: 1, green: 0.36, blue: 0.42)).frame(width: 7, height: 7)
                Circle().fill(Color(red: 1, green: 0.75, blue: 0.30)).frame(width: 7, height: 7)
                Circle().fill(Color(red: 0.30, green: 0.82, blue: 0.53)).frame(width: 7, height: 7)
                Text("LUA")
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(NovaPalette.muted)
                Spacer()
                Text("\(editorText.split(separator: "\n", omittingEmptySubsequences: false).count) LINES")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(NovaPalette.muted)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(NovaPalette.elevated)

            TextEditor(text: $editorText)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(red: 0.85, green: 0.81, blue: 1.0))
                .scrollContentBackground(.hidden)
                .tint(NovaPalette.lavender)
                .padding(10)
                .background(NovaPalette.surface)

            HStack {
                Label("LOCAL EDITOR", systemImage: "lock.fill")
                Spacer()
                Text("\(editorText.count) CHARS")
            }
            .font(.system(size: 9, weight: .bold))
            .tracking(1)
            .foregroundStyle(NovaPalette.muted)
            .padding(13)
            .background(NovaPalette.elevated)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var filesView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                pageTitle("File Center", subtitle: "Import and organize source files")

                Button {
                    showingImporter = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 27, weight: .medium))
                            .foregroundStyle(NovaPalette.lavender)
                        Text("Import a source file")
                            .font(.system(size: 15, weight: .bold))
                        Text("Choose a .lua, .txt, or supported source file")
                            .font(.system(size: 11))
                            .foregroundStyle(NovaPalette.muted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(NovaPalette.surface)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(NovaPalette.purple.opacity(0.45), style: StrokeStyle(lineWidth: 1, dash: [6])))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)

                sectionHeading("LOCAL FILES")
                ForEach(scripts) { script in
                    scriptRow(script)
                }
            }
            .padding(20)
        }
    }

    private var settingsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                pageTitle("Settings", subtitle: "Make Nova feel like yours")

                settingsRow(icon: "paintpalette.fill", title: "Appearance", detail: "Midnight violet")
                settingsRow(icon: "curlybraces", title: "Editor", detail: "Monospaced Lua workspace")
                settingsRow(icon: "externaldrive.fill", title: "Storage", detail: "Local project list")
                settingsRow(icon: "info.circle.fill", title: "About Nova", detail: "Version 1.0 • iOS")

                Text("Nova is an independent code-organizing interface. It is not affiliated with Delta or Roblox.")
                    .font(.system(size: 11))
                    .foregroundStyle(NovaPalette.muted)
                    .lineSpacing(4)
                    .padding(15)
                    .background(NovaPalette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(20)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(NovaTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 16, weight: .semibold))
                        Text(tab.rawValue.uppercased())
                            .font(.system(size: 8, weight: .heavy))
                            .tracking(0.5)
                    }
                    .foregroundStyle(selectedTab == tab ? NovaPalette.lavender : NovaPalette.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(NovaPalette.surface)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
        }
    }

    private var inspectorSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FILE INSPECTOR")
                .font(.system(size: 11, weight: .heavy))
                .tracking(2)
                .foregroundStyle(NovaPalette.lavender)

            Text(editorName)
                .font(.system(size: 20, weight: .bold, design: .rounded))

            HStack {
                inspectorMetric("LINES", value: "\(editorText.split(separator: "\n", omittingEmptySubsequences: false).count)")
                inspectorMetric("CHARACTERS", value: "\(editorText.count)")
                inspectorMetric("WORDS", value: "\(editorText.split { $0.isWhitespace || $0.isNewline }.count)")
            }

            Text("This is a text inspection summary. It does not execute the source file.")
                .font(.system(size: 12))
                .foregroundStyle(NovaPalette.muted)
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NovaPalette.background.ignoresSafeArea())
    }

    private func pageTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 27, weight: .black, design: .rounded))
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(NovaPalette.muted)
        }
        .padding(.top, 8)
    }

    private func sectionHeading(_ title: String, trailing: String? = nil, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 10, weight: .heavy))
                .tracking(1.8)
                .foregroundStyle(NovaPalette.muted)
            Spacer()
            if let trailing, let action {
                Button(trailing, action: action)
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(NovaPalette.lavender)
            }
        }
    }

    private func metricCard(title: String, value: String, icon: String, compact: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(NovaPalette.lavender)
                Spacer()
                Text(title)
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(NovaPalette.muted)
            }
            Text(value)
                .font(.system(size: compact ? 13 : 27, weight: .black, design: compact ? .monospaced : .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(NovaPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func scriptRow(_ script: NovaScript) -> some View {
        Button {
            selectedScriptID = script.id
            editorName = script.name.hasSuffix(".lua") ? script.name : script.name + ".lua"
            editorText = script.source
            selectedTab = .editor
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(NovaPalette.purple.opacity(0.18))
                    .frame(width: 42, height: 42)
                    .overlay {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(NovaPalette.lavender)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(script.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(script.source.count) characters • Lua source")
                        .font(.system(size: 10))
                        .foregroundStyle(NovaPalette.muted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(NovaPalette.muted)
            }
            .padding(12)
            .background(NovaPalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }

    private func settingsRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(NovaPalette.lavender)
                .frame(width: 38, height: 38)
                .background(NovaPalette.purple.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 13, weight: .bold))
                Text(detail).font(.system(size: 10)).foregroundStyle(NovaPalette.muted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(NovaPalette.muted)
        }
        .padding(13)
        .background(NovaPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func inspectorMetric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 9, weight: .heavy)).foregroundStyle(NovaPalette.muted)
            Text(value).font(.system(size: 22, weight: .black, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(NovaPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private func emptyState(icon: String, title: String, detail: String) -> some View {
        VStack(spacing: 9) {
            Image(systemName: icon).font(.system(size: 28)).foregroundStyle(NovaPalette.lavender)
            Text(title).font(.system(size: 15, weight: .bold))
            Text(detail).font(.system(size: 11)).foregroundStyle(NovaPalette.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(NovaPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func createScript() {
        let trimmed = newScriptName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let fileName = trimmed.hasSuffix(".lua") ? trimmed : trimmed + ".lua"
        let script = NovaScript(name: fileName, source: "-- \(fileName)\n\n")
        scripts.insert(script, at: 0)
        selectedScriptID = script.id
        editorName = fileName
        editorText = script.source
        newScriptName = ""
        selectedTab = .editor
    }

    private func saveCurrentScript() {
        if let selectedScriptID, let index = scripts.firstIndex(where: { $0.id == selectedScriptID }) {
            scripts[index].source = editorText
            scripts[index].name = editorName
            scripts[index].updated = .now
        } else {
            let script = NovaScript(name: editorName, source: editorText)
            scripts.insert(script, at: 0)
            selectedScriptID = script.id
        }
        notice = "Saved \(editorName) to the current Nova session."
    }

    private func importSource(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let didAccess = url.startAccessingSecurityScopedResource()
            defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                let source = try String(contentsOf: url, encoding: .utf8)
                let name = url.lastPathComponent
                let script = NovaScript(name: name, source: source)
                scripts.insert(script, at: 0)
                selectedScriptID = script.id
                editorName = name
                editorText = source
                selectedTab = .editor
                notice = "Imported \(name)."
            } catch {
                notice = "Couldn't read that file as UTF-8 text."
            }
        case .failure:
            notice = "The file import was cancelled or couldn't be completed."
        }
    }
}

#Preview {
    ContentView()
}
