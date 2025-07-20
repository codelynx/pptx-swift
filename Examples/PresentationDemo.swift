import SwiftUI
import PPTXKit

/// Demo app showing PPTXManager and presentation views
struct PresentationDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var manager = PPTXManager()
    @State private var showingFilePicker = false
    @State private var showingThumbnails = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Presentation View
            VStack {
                if manager.slideCount > 0 {
                    PPTXPresentationView(manager: manager)
                        .renderingQuality(.high)
                        .onSlideChange { index in
                            print("Navigated to slide \(index)")
                        }
                } else {
                    EmptyStateView {
                        loadSamplePresentation()
                    }
                }
            }
            .tabItem {
                Label("Presentation", systemImage: "play.rectangle")
            }
            .tag(0)
            
            // Thumbnail Grid
            VStack {
                if manager.slideCount > 0 {
                    PPTXThumbnailGridView(manager: manager)
                        .navigationTitle("Slides")
                } else {
                    EmptyStateView {
                        loadSamplePresentation()
                    }
                }
            }
            .tabItem {
                Label("Thumbnails", systemImage: "square.grid.2x2")
            }
            .tag(1)
            
            // Manager Controls
            ManagerControlsView(manager: manager)
                .tabItem {
                    Label("Controls", systemImage: "slider.horizontal.3")
                }
                .tag(2)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Load Sample") {
                    loadSamplePresentation()
                }
            }
        }
    }
    
    private func loadSamplePresentation() {
        do {
            // In a real app, this would load an actual file
            try manager.loadPresentation(from: "samples/sample1_SSI_Chap2.pptx")
        } catch {
            print("Failed to load presentation: \(error)")
        }
    }
}

struct EmptyStateView: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Presentation Loaded")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Load a PowerPoint file to get started")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("Load Sample Presentation", action: action)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ManagerControlsView: View {
    @ObservedObject var manager: PPTXManager
    @State private var searchText = ""
    @State private var searchResults: [Slide] = []
    
    var body: some View {
        Form {
            // Presentation Info
            Section("Presentation Info") {
                LabeledContent("Slide Count", value: "\(manager.slideCount)")
                LabeledContent("Current Slide", value: "\(manager.currentSlideIndex)")
                
                if let metadata = manager.metadata {
                    LabeledContent("Title", value: metadata.title ?? "Untitled")
                    LabeledContent("Author", value: metadata.author ?? "Unknown")
                }
                
                ProgressView(value: manager.progress)
                    .progressViewStyle(.linear)
            }
            
            // Navigation
            Section("Navigation") {
                HStack {
                    Button("First") { manager.goToFirst() }
                        .disabled(manager.currentSlideIndex == 1)
                    
                    Spacer()
                    
                    Button("Previous") { manager.goToPrevious() }
                        .disabled(!manager.canGoPrevious)
                    
                    Spacer()
                    
                    Button("Next") { manager.goToNext() }
                        .disabled(!manager.canGoNext)
                    
                    Spacer()
                    
                    Button("Last") { manager.goToLast() }
                        .disabled(manager.currentSlideIndex == manager.slideCount)
                }
                .buttonStyle(.bordered)
                
                // Direct navigation
                Picker("Go to Slide", selection: Binding(
                    get: { manager.currentSlideIndex },
                    set: { manager.goToSlide(at: $0) }
                )) {
                    ForEach(1...max(1, manager.slideCount), id: \.self) { index in
                        Text("Slide \(index)").tag(index)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Search
            Section("Search") {
                TextField("Search slides...", text: $searchText)
                    .onSubmit {
                        searchResults = manager.searchSlides(containing: searchText)
                    }
                
                if !searchResults.isEmpty {
                    ForEach(searchResults, id: \.id) { slide in
                        Button {
                            manager.goToSlide(withId: slide.id)
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Slide \(slide.index)")
                                    .font(.headline)
                                if let title = slide.title {
                                    Text(title)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            
            // Current Slide Info
            if let slide = manager.currentSlide {
                Section("Current Slide") {
                    LabeledContent("ID", value: slide.id)
                    LabeledContent("Title", value: slide.title ?? "No title")
                    LabeledContent("Shape Count", value: "\(slide.shapeCount)")
                    LabeledContent("Text Lines", value: "\(slide.textContent.count)")
                    
                    if !slide.textContent.isEmpty {
                        DisclosureGroup("Text Content") {
                            ForEach(Array(slide.textContent.enumerated()), id: \.offset) { index, text in
                                Text(text)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Manager Controls")
    }
}

// MARK: - UIKit Demo

#if canImport(UIKit)
import UIKit

class PresentationDemoViewController: UIViewController {
    private var manager: PPTXManager!
    private var presentationVC: PPTXPresentationViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create manager
        manager = PPTXManager()
        
        // Create presentation view controller
        presentationVC = PPTXPresentationViewController(manager: manager)
        
        // Add as child
        addChild(presentationVC)
        view.addSubview(presentationVC.view)
        presentationVC.view.frame = view.bounds
        presentationVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentationVC.didMove(toParent: self)
        
        // Load sample presentation
        loadSamplePresentation()
        
        // Add load button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Load",
            style: .plain,
            target: self,
            action: #selector(loadPresentation)
        )
    }
    
    private func loadSamplePresentation() {
        do {
            try manager.loadPresentation(from: "samples/sample1_SSI_Chap2.pptx")
        } catch {
            showError(error)
        }
    }
    
    @objc private func loadPresentation() {
        // In a real app, show file picker
        loadSamplePresentation()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// Demo app that shows thumbnail grid
class ThumbnailDemoViewController: UIViewController {
    private var manager: PPTXManager!
    private var thumbnailVC: PPTXThumbnailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create manager
        manager = PPTXManager()
        
        // Create thumbnail view controller
        thumbnailVC = PPTXThumbnailViewController(manager: manager)
        
        // Add as child
        addChild(thumbnailVC)
        view.addSubview(thumbnailVC.view)
        thumbnailVC.view.frame = view.bounds
        thumbnailVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        thumbnailVC.didMove(toParent: self)
        
        // Load sample presentation
        do {
            try manager.loadPresentation(from: "samples/sample1_SSI_Chap2.pptx")
        } catch {
            print("Failed to load: \(error)")
        }
    }
}
#endif