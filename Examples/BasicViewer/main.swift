import SwiftUI
import PPTXKit

// Basic SwiftUI app that displays a PowerPoint presentation

@main
struct BasicViewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var manager = PPTXManager()
    @State private var showFilePicker = false
    
    var body: some View {
        VStack {
            if manager.isLoaded {
                // Display the presentation
                PPTXPresentationView(manager: manager)
                    .navigationControlsVisible(true)
            } else {
                // Show file picker button
                VStack(spacing: 20) {
                    Text("PPTXKit Basic Viewer")
                        .font(.largeTitle)
                        .padding()
                    
                    Button("Open Presentation") {
                        showFilePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    do {
                        try manager.loadPresentation(from: url)
                    } catch {
                        print("Error loading presentation: \(error)")
                    }
                }
            case .failure(let error):
                print("Error selecting file: \(error)")
            }
        }
    }
}