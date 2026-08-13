import SwiftUI
import UIKit
import ObjectiveC
import UniformTypeIdentifiers

// Make the document picker always copy tendies into our sandbox so the
// returned URL is directly readable (same trick Pocket Poster uses).
extension UIDocumentPickerViewController {
    @objc func fix_init(forOpeningContentTypes contentTypes: [UTType], asCopy: Bool) -> UIDocumentPickerViewController {
        return fix_init(forOpeningContentTypes: contentTypes, asCopy: true)
    }
}

struct PosterBoardView: View {
    @ObservedObject private var pbManager = PosterBoardManager.shared
    @AppStorage("pbHash") private var pbHash: String = ""

    @State private var showTendiesImporter = false
    @State private var showResetConfirm = false
    @State private var isBusy = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private let tendieType: UTType = UTType("com.leminlimez.tendies")
        ?? UTType(filenameExtension: "tendies", conformingTo: .data)!

    init() {
        // Force asCopy: true so the picker hands back a copy we can read
        // without security scoping. Swap once so view recreations don't
        // undo the swizzle.
        Self.swizzleOnce
    }

    private static let swizzleOnce: Void = {
        let fixMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.fix_init(forOpeningContentTypes:asCopy:)))!
        let origMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:)))!
        method_exchangeImplementations(origMethod, fixMethod)
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        header
                        if !BadQuery.isAvailable {
                            unavailableNotice
                        }
                        importSection
                        if !pbManager.selectedTendies.isEmpty {
                            selectedSection
                        }
                        actionSection
                        footnotes
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                .scrollDismissesKeyboard(.interactively)

                if isBusy {
                    ProgressOverlay(message: "Applying tendies…")
                }
            }
            .navigationTitle("PosterBoard")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fileImporter(
            isPresented: $showTendiesImporter,
            allowedContentTypes: [tendieType],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    guard pbManager.selectedTendies.count < PosterBoardManager.MaxTendies else {
                        errorMessage = "You can only apply \(PosterBoardManager.MaxTendies) tendies."
                        showErrorAlert = true
                        break
                    }
                    do {
                        let imported = try pbManager.importTendies(from: url)
                        pbManager.selectedTendies.append(imported)
                    } catch {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
        .alert("Something went wrong", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog(
            "Reset Collections",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset Collections", role: .destructive) {
                resetCollections()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This wipes every custom PosterBoard descriptor. This cannot be undone.")
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 56, height: 56)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color(.tertiarySystemFill)))
            Text("PosterBoard")
                .font(.title.weight(.bold))
            Text("Inject wallpaper packs into the lock screen")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: Unavailable notice

    private var unavailableNotice: some View {
        Card {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(Theme.danger)
                VStack(alignment: .leading, spacing: 2) {
                    Text("bad_query unavailable")
                        .font(.subheadline.weight(.semibold))
                    Text("The bad_query sandbox escape is not resolving on this iOS version, so PosterBoard containers cannot be accessed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    // MARK: Import

    private var importSection: some View {
        Card {
            ActionButton(
                title: "Select Tendies",
                systemImage: "doc",
                action: {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showTendiesImporter.toggle()
                }
            )
            Text("Tendies are .tendies ZIP packs containing PosterBoard wallpaper descriptors, made for Pocket Poster.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: Selected

    private var selectedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "Selected Tendies")
            RowGroup {
                ForEach(Array(pbManager.selectedTendies.enumerated()), id: \.element) { index, tendie in
                    HStack(spacing: 10) {
                        Image(systemName: "doc.zipper")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(tendie.deletingPathExtension().lastPathComponent)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                        Button {
                            withAnimation { remove(tendie) }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.body)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    if index < pbManager.selectedTendies.count - 1 {
                        RowDivider(inset: 40)
                    }
                }
            }
        }
    }

    // MARK: Actions

    @ViewBuilder
    private var actionSection: some View {
        if BadQuery.isAvailable {
            Card {
                if pbHash.isEmpty {
                    Text("No PosterBoard hash saved — it will be auto-detected on Apply via bad_query.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ActionButton(
                    title: "Apply",
                    systemImage: "checkmark",
                    isBusy: isBusy,
                    disabled: pbManager.selectedTendies.isEmpty,
                    action: applyTendies
                )

                TonalButton(
                    title: "Reset Collections",
                    systemImage: "arrow.clockwise",
                    tint: Theme.danger,
                    action: { showResetConfirm = true }
                )
                .disabled(isBusy)

                TextButton(
                    title: "Open PosterBoard",
                    systemImage: "safari",
                    action: {
                        if !pbManager.openPosterBoard() {
                            errorMessage = "Could not open PosterBoard. Make sure you're on a supported iOS version and the Wallpaper app has been opened once."
                            showErrorAlert = true
                        }
                    }
                )
                .disabled(isBusy)
            }
        }
    }

    // MARK: Footnotes

    private var footnotes: some View {
        VStack(spacing: 6) {
            Text("Applying injects the selected tendies into PosterBoard's extension data store, then resprings to rebuild the wallpaper library.")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("Reset Collections wipes every custom descriptor so you can start over.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }

    // MARK: Actions

    private func remove(_ tendie: URL) {
        pbManager.selectedTendies.removeAll { $0 == tendie }
        try? FileManager.default.removeItem(at: tendie)
    }

    private func applyTendies() {
        guard !pbManager.selectedTendies.isEmpty, !isBusy else { return }
        isBusy = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var hash = pbHash
                if hash.isEmpty {
                    hash = try BadQuery.findPosterBoardHash()
                    DispatchQueue.main.async { pbHash = hash }
                }
                try pbManager.applyTendies(appHash: hash)
                DispatchQueue.main.async {
                    pbManager.selectedTendies.removeAll()
                    isBusy = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    RespringHelper.respring()
                }
            } catch {
                DispatchQueue.main.async {
                    isBusy = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }

    private func resetCollections() {
        guard !isBusy else { return }
        isBusy = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var hash = pbHash
                if hash.isEmpty {
                    hash = try BadQuery.findPosterBoardHash()
                    DispatchQueue.main.async { pbHash = hash }
                }
                try pbManager.resetCollections(appHash: hash)
                DispatchQueue.main.async {
                    isBusy = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    RespringHelper.respring()
                }
            } catch {
                DispatchQueue.main.async {
                    isBusy = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}
