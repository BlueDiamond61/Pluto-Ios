import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var script = "-- Welcome to Pluto\n\nprint(\"Hello, Pluto!\")"
    @State private var console = "Pluto initialized.\nReady."
    @State private var showSettings = false

    private let purple = Color(red: 0.58, green: 0.35, blue: 0.95)
    private let background = Color(red: 0.055, green: 0.045, blue: 0.085)
    private let panel = Color(red: 0.105, green: 0.085, blue: 0.15)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Group {
                    switch selectedTab {
                    case 0: homeView
                    case 1: editorView
                    case 2: consoleView
                    default: settingsView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomNavigation
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(purple.opacity(0.2))
                    .frame(width: 42, height: 42)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(purple)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("PLUTO")
                    .font(.system(size: 20, weight: .heavy))
                    .tracking(2)

                Text("iOS DEVELOPMENT")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button {
                showSettings = true
                selectedTab = 3
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(12)
                    .background(panel)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: Home

    private var homeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("WELCOME BACK")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundColor(purple)

                    Text("Your workspace.\nYour control.")
                        .font(.system(size: 30, weight: .bold))

                    Text("A clean workspace for your native development projects.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 15)

                HStack(spacing: 12) {
                    statusCard(
                        title: "VERSION",
                        value: "1.0.0",
                        icon: "number"
                    )

                    statusCard(
                        title: "PLATFORM",
                        value: "iOS",
                        icon: "iphone"
                    )
                }

                VStack(alignment: .leading, spacing: 15) {
                    sectionTitle("QUICK ACTIONS")

                    actionButton(
                        title: "Open Editor",
                        subtitle: "Write and manage your scripts",
                        icon: "chevron.left.forwardslash.chevron.right"
                    ) {
                        selectedTab = 1
                    }

                    actionButton(
                        title: "View Console",
                        subtitle: "View local application messages",
                        icon: "terminal"
                    ) {
                        selectedTab = 2
                    }

                    actionButton(
                        title: "Settings",
                        subtitle: "Customize your Pluto experience",
                        icon: "slider.horizontal.3"
                    ) {
                        selectedTab = 3
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("ABOUT PLUTO")

                    Text("Pluto is a native iOS interface built with SwiftUI, designed around a simple editor, console, and customizable workspace.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineSpacing(5)
                }
                .padding(17)
                .background(panel)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(20)
        }
    }

    // MARK: Editor

    private var editorView: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Script Editor")
                        .font(.system(size: 21, weight: .bold))

                    Text("Untitled.lua")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                Button {
                    script = ""
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .padding(11)
                        .background(panel)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            VStack(spacing: 0) {
                HStack {
                    Circle().fill(.red).frame(width: 8, height: 8)
                    Circle().fill(.yellow).frame(width: 8, height: 8)
                    Circle().fill(.green).frame(width: 8, height: 8)

                    Text("PLUTO EDITOR")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(.gray)

                    Spacer()

                    Text("LUA")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(purple)
                }
                .padding(14)
                .background(Color.white.opacity(0.035))

                TextEditor(text: $script)
                    .font(.system(size: 14, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.95))
                    .padding(10)
                    .frame(minHeight: 300)
                    .background(panel)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button {
                console += "\nEditor preview requested."
                selectedTab = 2
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Preview")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(purple)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Text("Preview only — no code is executed.")
                .font(.system(size: 11))
                .foregroundColor(.gray)

            Spacer()
        }
        .padding(20)
    }

    // MARK: Console

    private var consoleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Console")
                    .font(.system(size: 23, weight: .bold))

                Spacer()

                Button("Clear") {
                    console = ""
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(purple)
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(.green)
                    .frame(width: 7, height: 7)

                Text("LOCAL APPLICATION LOG")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(.gray)
            }

            ScrollView {
                Text(console.isEmpty ? "No messages." : console)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.green.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
            }
            .background(panel)
            .clipShape(RoundedRectangle(cornerRadius: 15))

            Spacer()
        }
        .padding(20)
    }

    // MARK: Settings

    private var settingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Settings")
                    .font(.system(size: 24, weight: .bold))

                settingsRow("Appearance", detail: "Dark mode", icon: "moon.fill")
                settingsRow("Accent Color", detail: "Pluto Purple", icon: "paintpalette.fill")
                settingsRow("Editor", detail: "Monospaced font", icon: "curlybraces")
                settingsRow("About", detail: "Pluto v1.0.0", icon: "info.circle.fill")
            }
            .padding(20)
        }
    }

    // MARK: Navigation

    private var bottomNavigation: some View {
        HStack {
            navigationItem("Home", icon: "house.fill", index: 0)
            navigationItem("Editor", icon: "chevron.left.forwardslash.chevron.right", index: 1)
            navigationItem("Console", icon: "terminal.fill", index: 2)
            navigationItem("Settings", icon: "gearshape.fill", index: 3)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(panel)
    }

    private func navigationItem(
        _ title: String,
        icon: String,
        index: Int
    ) -> some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))

                Text(title)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(selectedTab == index ? purple : .gray)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Components

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.5)
            .foregroundColor(.gray)
    }

    private func statusCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(purple)

            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 20, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func actionButton(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 19))
                    .foregroundColor(purple)
                    .frame(width: 42, height: 42)
                    .background(purple.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
            }
            .padding(13)
            .background(panel)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }

    private func settingsRow(
        _ title: String,
        detail: String,
        icon: String
    ) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .foregroundColor(purple)
                .frame(width: 38, height: 38)
                .background(purple.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))

                Text(detail)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 12))
        }
        .padding(14)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    ContentView()
}
