import SwiftUI
import Security
import UniformTypeIdentifiers
import UIKit

enum PlutoTab: Int, CaseIterable {
    case dashboard
    case ipaManager
    case certificates
    case signing
    case installation
    case settings
}

enum ImportType {
    case ipa
    case p12
    case provisioningProfile
}

struct ImportedIPA: Identifiable {
    let id = UUID()
    let name: String
    let version: String
    let bundleID: String
    let size: String
    let importedAt: String
    let iconLetter: String
}

struct SigningIdentity: Identifiable {
    let id = UUID()
    let name: String
    let expiresAt: String
    let status: String
    let isValid: Bool
}

struct ProvisioningProfile: Identifiable {
    let id = UUID()
    let name: String
    let bundleID: String
    let expiresAt: String
    let compatible: Bool
}

final class KeychainManager {
    static func save(value: String, for key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}

struct ContentView: View {
    @State private var selectedTab: PlutoTab = .dashboard
    @State private var importType: ImportType = .ipa
    @State private var showingDocumentPicker = false
    @State private var importedIPAs: [ImportedIPA] = [
        ImportedIPA(name: "Pluto Sign Demo", version: "1.4.2", bundleID: "com.plutolabs.sign.demo", size: "84.3 MB", importedAt: "2h ago", iconLetter: "P"),
        ImportedIPA(name: "BlueShift", version: "3.2.0", bundleID: "com.blueshift.app", size: "152 MB", importedAt: "Yesterday", iconLetter: "B"),
        ImportedIPA(name: "Nova Wallet", version: "2.8.1", bundleID: "co.nova.wallet", size: "126 MB", importedAt: "3 days ago", iconLetter: "N")
    ]
    @State private var signingIdentities: [SigningIdentity] = [
        SigningIdentity(name: "Apple Distribution - Pluto Labs", expiresAt: "2027-11-12", status: "Valid", isValid: true),
        SigningIdentity(name: "iPhone Distribution - Team 4A", expiresAt: "2026-08-18", status: "Expiring soon", isValid: true)
    ]
    @State private var profiles: [ProvisioningProfile] = [
        ProvisioningProfile(name: "Pluto Sign App Profile", bundleID: "com.plutolabs.sign.demo", expiresAt: "2027-03-10", compatible: true),
        ProvisioningProfile(name: "BlueShift Ad Hoc", bundleID: "com.blueshift.app", expiresAt: "2026-12-05", compatible: true),
        ProvisioningProfile(name: "Legacy Profile", bundleID: "com.example.old", expiresAt: "2025-05-01", compatible: false)
    ]
    @State private var recentActivity: [String] = [
        "Imported BlueShift.ipa",
        "Validated Pluto Labs certificate",
        "Profile compatibility check passed",
        "Signing session prepared"
    ]
    @State private var selectedIPA: ImportedIPA? = nil
    @State private var selectedIdentity: SigningIdentity? = nil
    @State private var selectedProfile: ProvisioningProfile? = nil
    @State private var signingProgress: Double = 0
    @State private var signingStatus: String = "Ready to prepare signed package"
    @State private var installationStatus: String = "Awaiting installation method"

    private let purple = Color(red: 0.58, green: 0.35, blue: 0.95)
    private let deepPurple = Color(red: 0.35, green: 0.22, blue: 0.62)
    private let background = Color(red: 0.055, green: 0.045, blue: 0.085)
    private let panel = Color(red: 0.105, green: 0.085, blue: 0.15)
    private let cardAlt = Color(red: 0.13, green: 0.10, blue: 0.18)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                Group {
                    switch selectedTab {
                    case .dashboard:
                        dashboardView
                    case .ipaManager:
                        ipaManagerView
                    case .certificates:
                        certificatesView
                    case .signing:
                        signingView
                    case .installation:
                        installationView
                    case .settings:
                        settingsView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomNavigation
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPickerView(type: importType) { url in
                handleImportedURL(url)
            }
        }
    }

    private var headerView: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [purple, deepPurple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)

                Image(systemName: "seal.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("PLUTO SIGN")
                    .font(.system(size: 21, weight: .heavy))
                    .tracking(1.8)

                Text("ANDROID / iOS SIGNING")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button {
                selectedTab = .settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white.opacity(0.85))
                    .font(.system(size: 18, weight: .semibold))
                    .padding(12)
                    .background(panel)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var dashboardView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("DASHBOARD")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundColor(purple)

                    Text("Secure signing workspace")
                        .font(.system(size: 30, weight: .heavy))

                    Text("Manage packages, certificates, profiles, and prepare signed builds through an authorized macOS signing service.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding(.top, 8)

                HStack(spacing: 12) {
                    metricCard(title: "Imported IPAs", value: "\(importedIPAs.count)", icon: "archivebox.fill")
                    metricCard(title: "Identities", value: "\(signingIdentities.count)", icon: "shield.fill")
                }

                Button {
                    importType = .ipa
                    showingDocumentPicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Import IPA")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(LinearGradient(colors: [purple, deepPurple], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 14) {
                    sectionHeader("RECENT ACTIVITY")

                    ForEach(recentActivity.indices, id: \ .self) { index in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(index % 2 == 0 ? purple : .green)
                                .frame(width: 8, height: 8)

                            Text(recentActivity[index])
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.85))

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(16)
                .background(panel)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(20)
        }
    }

    private var ipaManagerView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sectionHeader("IPA MANAGER")

                Button {
                    importType = .ipa
                    showingDocumentPicker = true
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Import IPA")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(panel)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                VStack(spacing: 12) {
                    ForEach(importedIPAs) { ipa in
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(LinearGradient(colors: [purple.opacity(0.4), deepPurple.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 54, height: 54)

                                Text(ipa.iconLetter)
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(ipa.name)
                                    .font(.system(size: 16, weight: .bold))

                                Text("v\(ipa.version) • \(ipa.bundleID)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)

                                Text("\(ipa.size) • Imported \(ipa.importedAt)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            VStack(spacing: 8) {
                                Button {
                                    selectedIPA = ipa
                                    selectedTab = .signing
                                } label: {
                                    Text("Select")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(purple)
                                }

                                Button(role: .destructive) {
                                    importedIPAs.removeAll { $0.id == ipa.id }
                                } label: {
                                    Text("Delete")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(14)
                        .background(panel)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
            .padding(20)
        }
    }

    private var certificatesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sectionHeader("CERTIFICATE MANAGER")

                HStack(spacing: 12) {
                    actionPill(title: "Import P12", icon: "doc.badge.plus") {
                        importType = .p12
                        showingDocumentPicker = true
                    }

                    actionPill(title: "Import Profile", icon: "filemenu.and.selection") {
                        importType = .provisioningProfile
                        showingDocumentPicker = true
                    }
                }

                VStack(spacing: 12) {
                    ForEach(signingIdentities) { identity in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: identity.isValid ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(identity.isValid ? .green : .orange)

                                Text(identity.name)
                                    .font(.system(size: 15, weight: .bold))

                                Spacer()

                                Text(identity.status)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(identity.isValid ? .green : .orange)
                            }

                            Text("Expires: \(identity.expiresAt)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(14)
                        .background(panel)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("PROFILES")

                    ForEach(profiles) { profile in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(profile.name)
                                    .font(.system(size: 14, weight: .semibold))

                                Spacer()

                                Text(profile.compatible ? "Compatible" : "Mismatch")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(profile.compatible ? .green : .orange)
                            }

                            Text("Bundle ID: \(profile.bundleID)")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)

                            Text("Expires: \(profile.expiresAt)")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(cardAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(20)
        }
    }

    private var signingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sectionHeader("SIGNING")

                VStack(alignment: .leading, spacing: 12) {
                    selectionField(label: "IPA", value: selectedIPA?.name ?? "Select imported IPA")
                    selectionField(label: "Certificate", value: signingIdentities.first?.name ?? "Select certificate")
                    selectionField(label: "Profile", value: profiles.first?.name ?? "Select provisioning profile")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Compatibility check")
                        .font(.system(size: 13, weight: .bold))

                    HStack {
                        statusPill(title: "Bundle ID", color: .green)
                        statusPill(title: "Entitlements", color: .green)
                        statusPill(title: "Team match", color: .green)
                    }
                }
                .padding(16)
                .background(panel)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Button {
                    prepareSigningFlow()
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Prepare Signed IPA")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .foregroundColor(.white)
                    .background(LinearGradient(colors: [purple, deepPurple], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Signing progress")
                        .font(.system(size: 13, weight: .bold))

                    ProgressView(value: signingProgress, total: 1)
                        .tint(purple)

                    Text(signingStatus)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(panel)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("This app prepares a signed IPA through an authorized macOS signing service. It does not bypass Certificate, Provisioning, or Apple installation restrictions.")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .padding(20)
        }
    }

    private var installationView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sectionHeader("INSTALLATION")

                VStack(spacing: 12) {
                    infoCard(title: "TestFlight", description: "Use App Store Connect to distribute a signed build to registered testers.")
                    infoCard(title: "Ad Hoc / Registered devices", description: "Install via OTA or device management for enrolled devices only.")
                    infoCard(title: "Official Apple workflow", description: "Use Apple's supported signing and distribution service for deployment.")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Current status")
                        .font(.system(size: 13, weight: .bold))

                    Text(installationStatus)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(16)
                .background(panel)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(20)
        }
    }

    private var settingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sectionHeader("SETTINGS")

                settingsRow(title: "Theme", detail: "Dark mode / premium violet")
                settingsRow(title: "Storage", detail: "Manage imported packages and signed outputs")
                settingsRow(title: "Certificate management", detail: "Review identities and provisioning profiles")
                settingsRow(title: "About Pluto Sign", detail: "Version 1.0.0 • Secure archive workflow")

                VStack(alignment: .leading, spacing: 14) {
                    Text("Keychain")
                        .font(.system(size: 13, weight: .bold))

                    Text("Sensitive signing credentials are stored in the iOS Keychain when available.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(panel)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(20)
        }
    }

    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            navigationButton(title: "Dashboard", icon: "house.fill", tab: .dashboard)
            navigationButton(title: "IPAs", icon: "archivebox.fill", tab: .ipaManager)
            navigationButton(title: "Certs", icon: "shield.fill", tab: .certificates)
            navigationButton(title: "Sign", icon: "wand.and.stars", tab: .signing)
            navigationButton(title: "Install", icon: "arrow.down.circle.fill", tab: .installation)
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(panel)
    }

    private func navigationButton(title: String, icon: String, tab: PlutoTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))

                Text(title)
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundColor(selectedTab == tab ? purple : .gray)
            .frame(maxWidth: .infinity)
        }
    }

    private func prepareSigningFlow() {
        signingProgress = 0
        signingStatus = "Checking bundle ID and entitlements…"

        Task {
            for step in 1...5 {
                try? await Task.sleep(nanoseconds: 300_000_000)
                await MainActor.run {
                    signingProgress = Double(step) / 5.0
                    switch step {
                    case 1:
                        signingStatus = "Verifying certificate and profile match…"
                    case 2:
                        signingStatus = "Validating entitlement compatibility…"
                    case 3:
                        signingStatus = "Packaging signed IPA payload…"
                    case 4:
                        signingStatus = "Sending to authorized macOS signing service…"
                    default:
                        signingStatus = "Signed package ready for TestFlight or Ad Hoc distribution"
                        installationStatus = "Ready for official distribution workflow"
                    }
                }
            }
        }
    }

    private func handleImportedURL(_ url: URL) {
        let extensionName = url.pathExtension.lowercased()

        switch importType {
        case .ipa:
            let name = url.deletingPathExtension().lastPathComponent
            let newIPA = ImportedIPA(
                name: name.isEmpty ? "Custom IPA" : name,
                version: "1.0.0",
                bundleID: "com.plutolabs.custom",
                size: "87.5 MB",
                importedAt: "Just now",
                iconLetter: String(name.prefix(1).uppercased())
            )
            importedIPAs.insert(newIPA, at: 0)
            selectedIPA = newIPA
            recentActivity.insert("Imported \(newIPA.name).ipa", at: 0)
            KeychainManager.save(value: newIPA.bundleID, for: "pluto:last_imported_bundle")
        case .p12:
            signingIdentities.insert(
                SigningIdentity(name: "Imported certificate \(extensionName.uppercased())", expiresAt: "2028-10-05", status: "Ready", isValid: true),
                at: 0
            )
            recentActivity.insert("Imported certificate payload", at: 0)
        case .provisioningProfile:
            profiles.insert(
                ProvisioningProfile(name: "Imported profile", bundleID: "com.plutolabs.custom", expiresAt: "2028-02-01", compatible: true),
                at: 0
            )
            recentActivity.insert("Imported provisioning profile", at: 0)
        }
    }

    private func metricCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(purple)
                Spacer()
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }

            Text(value)
                .font(.system(size: 28, weight: .heavy))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.8)
            .foregroundColor(purple)
    }

    private func actionPill(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(panel)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func statusPill(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 10, weight: .bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func selectionField(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(panel)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func settingsRow(title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "chevron.right")
                .foregroundColor(purple)
                .font(.system(size: 12, weight: .bold))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))

                Text(detail)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(14)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoCard(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 15, weight: .bold))

            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    let type: ImportType
    let completion: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let utTypes: [UTType]

        switch type {
        case .ipa:
            utTypes = [UTType(filenameExtension: "ipa") ?? .data]
        case .p12:
            utTypes = [UTType(filenameExtension: "p12") ?? .data]
        case .provisioningProfile:
            utTypes = [UTType(filenameExtension: "mobileprovision") ?? .data]
        }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: utTypes, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL) -> Void

        init(completion: @escaping (URL) -> Void) {
            self.completion = completion
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            completion(url)
        }
    }
}

#Preview {
    ContentView()
}
