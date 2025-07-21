import SwiftUI
import PPTXKit
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var manager = PPTXManager()
    @State private var showingFilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var selectedView = ViewMode.presentation
    @State private var sidebarSelection: String? = "presentation"
    
    enum ViewMode: String, CaseIterable {
        case presentation = "Presentation"
        case thumbnails = "Thumbnails"
        case outline = "Outline"
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $sidebarSelection) {
                Section("Views") {
                    Label("Presentation", systemImage: "play.rectangle")
                        .tag("presentation")
                    Label("Thumbnails", systemImage: "square.grid.2x2")
                        .tag("thumbnails")
                    Label("Outline", systemImage: "list.bullet.indent")
                        .tag("outline")
                }
                
                if manager.slideCount > 0 {
                    Section("Slides") {
                        ForEach(1...manager.slideCount, id: \.self) { index in
                            HStack {
                                Text("Slide \(index)")
                                if index == manager.currentSlideIndex {
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .tag("slide-\(index)")
                            .onTapGesture {
                                print("📍 Sidebar: Tapped slide \(index)")
                                manager.goToSlide(at: index)
                                sidebarSelection = "slide-\(index)"
                                print("   → Manager current slide: \(manager.currentSlideIndex)")
                                print("   → Sidebar selection: \(sidebarSelection ?? "nil")")
                            }
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            // Main content area
            if manager.slideCount > 0 {
                // print("🔄 Detail view update - selection: \(sidebarSelection ?? "nil"), current slide: \(manager.currentSlideIndex)")
                switch sidebarSelection {
                case "presentation":
                    PresentationMainView(manager: manager, sidebarSelection: $sidebarSelection)
                case "thumbnails":
                    ThumbnailsMainView(manager: manager, sidebarSelection: $sidebarSelection)
                case "outline":
                    OutlineMainView(manager: manager, sidebarSelection: $sidebarSelection)
                default:
                    if let slideString = sidebarSelection,
                       slideString.hasPrefix("slide-"),
                       let index = Int(slideString.dropFirst(6)) {
                        // print("📊 Showing individual slide view for slide \(index)")
                        // Show specific slide
                        VStack {
                            if let slide = manager.slide(at: index), let document = manager.document {
                                // print("   ✅ Slide loaded: \(slide.title ?? "No title")")
                                PPTXSlideViewUI(document: document, slideIndex: index)
                                    .renderingQuality(.high)
                                    .padding()
                                    .id(slide.id)
                            } else {
                                // print("   ❌ Failed to load slide at index \(index)")
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(NSColor.windowBackgroundColor))
                    }
                }
            } else {
                EmptyStateView {
                    showingFilePicker = true
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "pptx") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenFile"))) { _ in
            showingFilePicker = true
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            loadPresentation(from: url)
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func loadPresentation(from url: URL) {
        print("📁 Loading presentation from: \(url.path)")
        do {
            try manager.loadPresentation(from: url.path)
            sidebarSelection = "presentation"
            print("   ✅ Loaded \(manager.slideCount) slides")
            print("   → Current slide: \(manager.currentSlideIndex)")
            print("   → Sidebar selection: \(sidebarSelection ?? "nil")")
        } catch {
            print("   ❌ Error loading: \(error)")
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

struct PresentationMainView: View {
    @ObservedObject var manager: PPTXManager
    @Binding var sidebarSelection: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button(action: { 
                    print("⬅️ Previous button pressed")
                    manager.goToPrevious()
                    if sidebarSelection?.hasPrefix("slide-") == true {
                        sidebarSelection = "slide-\(manager.currentSlideIndex)"
                        print("   → Updated sidebar selection to: \(sidebarSelection ?? "nil")")
                    }
                }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!manager.canGoPrevious)
                .keyboardShortcut(.leftArrow, modifiers: [])
                
                Text("Slide \(manager.currentSlideIndex) of \(manager.slideCount)")
                    .font(.headline)
                    .frame(minWidth: 150)
                
                Button(action: { 
                    print("➡️ Next button pressed")
                    manager.goToNext()
                    if sidebarSelection?.hasPrefix("slide-") == true {
                        sidebarSelection = "slide-\(manager.currentSlideIndex)"
                        print("   → Updated sidebar selection to: \(sidebarSelection ?? "nil")")
                    }
                }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!manager.canGoNext)
                .keyboardShortcut(.rightArrow, modifiers: [])
                
                Spacer()
                
                if let metadata = manager.metadata, let title = metadata.title {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Progress bar
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.accentColor.opacity(0.3))
                    .frame(width: geometry.size.width * manager.progress, height: 2)
            }
            .frame(height: 2)
            
            // Slide view
            PPTXPresentationView(manager: manager)
                .navigationControlsVisible(false)
                .progressBarVisible(false)
                .renderingQuality(.high)
        }
    }
}

struct ThumbnailsMainView: View {
    @ObservedObject var manager: PPTXManager
    @Binding var sidebarSelection: String?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 16)], spacing: 16) {
                ForEach(Array(manager.allSlides().enumerated()), id: \.element.id) { index, slide in
                    ThumbnailView(
                        manager: manager,
                        slide: slide,
                        index: index + 1,
                        isSelected: manager.currentSlideIndex == index + 1
                    ) {
                        manager.goToSlide(at: index + 1)
                        sidebarSelection = "slide-\(index + 1)"
                    }
                }
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private struct ThumbnailView: View {
        let manager: PPTXManager
        let slide: Slide
        let index: Int
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 8) {
                    // Slide preview
                    Group {
                        if let document = manager.document {
                            PPTXSlideViewUI(document: document, slideIndex: index)
                                .renderingQuality(.low)
                                .frame(height: 150)
                        } else {
                            PPTXSlideViewUI(slide: slide)
                                .renderingQuality(.low)
                                .frame(height: 150)
                        }
                    }
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                        )
                        .id(slide.id)
                    
                    // Slide info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Slide \(index)")
                            .font(.headline)
                        if let title = slide.title {
                            Text(title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct OutlineMainView: View {
    @ObservedObject var manager: PPTXManager
    @Binding var sidebarSelection: String?
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar
            slideList
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search slides...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var slideList: some View {
        List {
            ForEach(filteredSlides, id: \.id) { slide in
                SlideRowView(
                    slide: slide,
                    isCurrentSlide: slide.index == manager.currentSlideIndex,
                    onTap: {
                        manager.goToSlide(at: slide.index)
                        sidebarSelection = "slide-\(slide.index)"
                    }
                )
            }
        }
    }
    
    private var filteredSlides: [Slide] {
        if searchText.isEmpty {
            return manager.allSlides()
        } else {
            return manager.searchSlides(containing: searchText)
        }
    }
}

struct SlideRowView: View {
    let slide: Slide
    let isCurrentSlide: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            headerView
            titleView
            contentPreview
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private var headerView: some View {
        HStack {
            Text("Slide \(slide.index)")
                .font(.headline)
            if isCurrentSlide {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    @ViewBuilder
    private var titleView: some View {
        if let title = slide.title {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var contentPreview: some View {
        let previewItems = Array(slide.textContent.prefix(3).enumerated())
        
        ForEach(previewItems, id: \.offset) { _, text in
            Text("• \(text)")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        
        if slide.textContent.count > 3 {
            Text("... and \(slide.textContent.count - 3) more items")
                .font(.caption)
                .foregroundColor(Color.secondary.opacity(0.5))
        }
    }
}

struct EmptyStateView: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 72))
                .foregroundColor(.secondary)
            
            Text("No Presentation")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Open a PowerPoint file to get started")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: action) {
                Label("Open File", systemImage: "folder")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut("o", modifiers: .command)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}