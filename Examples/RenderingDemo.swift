import SwiftUI
import PPTXKit

/// Demo app for testing PPTX slide rendering
struct RenderingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var document: PPTXDocument?
    @State private var currentSlideIndex = 1
    @State private var slideCount = 0
    @State private var errorMessage: String?
    @State private var renderingQuality: RenderingQuality = .balanced
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("PPTX Rendering Demo")
                .font(.largeTitle)
                .padding()
            
            // File selection
            HStack {
                Text("File: \(document == nil ? "No file loaded" : "sample1_SSI_Chap2.pptx")")
                Spacer()
                Button("Load Sample") {
                    loadSampleFile()
                }
            }
            .padding(.horizontal)
            
            // Slide view
            if let document = document {
                PPTXSlideViewUI(document: document, slideIndex: currentSlideIndex)
                    .renderingQuality(renderingQuality)
                    .frame(width: 800, height: 600)
                    .background(Color.gray.opacity(0.1))
                    .border(Color.gray, width: 1)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 800, height: 600)
                    .overlay(
                        Text("No slide loaded")
                            .foregroundColor(.gray)
                    )
            }
            
            // Controls
            VStack(spacing: 10) {
                // Navigation
                HStack(spacing: 20) {
                    Button("Previous") {
                        if currentSlideIndex > 1 {
                            currentSlideIndex -= 1
                        }
                    }
                    .disabled(currentSlideIndex <= 1)
                    
                    Text("Slide \(currentSlideIndex) of \(slideCount)")
                        .frame(width: 150)
                    
                    Button("Next") {
                        if currentSlideIndex < slideCount {
                            currentSlideIndex += 1
                        }
                    }
                    .disabled(currentSlideIndex >= slideCount)
                }
                
                // Quality selector
                Picker("Rendering Quality", selection: $renderingQuality) {
                    Text("Low").tag(RenderingQuality.low)
                    Text("Balanced").tag(RenderingQuality.balanced)
                    Text("High").tag(RenderingQuality.high)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 300)
            }
            .padding()
            
            // Error display
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .frame(width: 1000, height: 800)
        .onAppear {
            loadSampleFile()
        }
    }
    
    private func loadSampleFile() {
        do {
            // In a real app, this would use a file picker
            let path = "samples/sample1_SSI_Chap2.pptx"
            document = try PPTXDocument(filePath: path)
            slideCount = try document?.getSlideCount() ?? 0
            currentSlideIndex = 1
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load file: \(error.localizedDescription)"
            document = nil
            slideCount = 0
        }
    }
}

// MARK: - UIKit Demo (iOS)

#if canImport(UIKit)
import UIKit

class RenderingDemoViewController: UIViewController {
    private var slideView: PPTXSlideView!
    private var document: PPTXDocument?
    private var currentSlideIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadSampleFile()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Create slide view
        slideView = PPTXSlideView(frame: .zero)
        slideView.translatesAutoresizingMaskIntoConstraints = false
        slideView.backgroundColor = .systemGray6
        view.addSubview(slideView)
        
        // Create navigation buttons
        let previousButton = UIButton(type: .system)
        previousButton.setTitle("Previous", for: .normal)
        previousButton.addTarget(self, action: #selector(previousSlide), for: .touchUpInside)
        
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(nextSlide), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [previousButton, nextButton])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Layout
        NSLayoutConstraint.activate([
            slideView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            slideView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slideView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            slideView.heightAnchor.constraint(equalTo: slideView.widthAnchor, multiplier: 0.75),
            
            stackView.topAnchor.constraint(equalTo: slideView.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func loadSampleFile() {
        do {
            let path = "samples/sample1_SSI_Chap2.pptx"
            document = try PPTXDocument(filePath: path)
            updateSlideView()
        } catch {
            print("Failed to load file: \(error)")
        }
    }
    
    private func updateSlideView() {
        guard let document = document else { return }
        
        // Create new slide view with document for image support
        let newSlideView = PPTXSlideView(document: document, slideIndex: currentSlideIndex, frame: slideView.frame)
        newSlideView.renderingQuality = .high
        
        // Replace the old slide view
        slideView.removeFromSuperview()
        slideView = newSlideView
        slideView.translatesAutoresizingMaskIntoConstraints = false
        slideView.backgroundColor = .systemGray6
        view.addSubview(slideView)
        
        // Re-apply constraints
        NSLayoutConstraint.activate([
            slideView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            slideView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slideView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            slideView.heightAnchor.constraint(equalTo: slideView.widthAnchor, multiplier: 0.75)
        ])
    }
    
    @objc private func previousSlide() {
        if currentSlideIndex > 1 {
            currentSlideIndex -= 1
            updateSlideView()
        }
    }
    
    @objc private func nextSlide() {
        if let document = document,
           let count = try? document.getSlideCount(),
           currentSlideIndex < count {
            currentSlideIndex += 1
            updateSlideView()
        }
    }
}
#endif

// MARK: - AppKit Demo (macOS)

#if canImport(AppKit)
import AppKit

class RenderingDemoWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "PPTX Rendering Demo"
        window.center()
        
        self.init(window: window)
        
        let viewController = RenderingDemoViewController()
        window.contentViewController = viewController
    }
}

class RenderingDemoViewController: NSViewController {
    private var slideView: PPTXSlideView!
    private var document: PPTXDocument?
    private var currentSlideIndex = 1
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 800))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadSampleFile()
    }
    
    private func setupUI() {
        // Create slide view
        slideView = PPTXSlideView(frame: NSRect(x: 50, y: 100, width: 900, height: 600))
        slideView.wantsLayer = true
        slideView.layer?.backgroundColor = NSColor.systemGray.cgColor
        view.addSubview(slideView)
        
        // Create navigation buttons
        let previousButton = NSButton(title: "Previous", target: self, action: #selector(previousSlide))
        previousButton.frame = NSRect(x: 350, y: 50, width: 100, height: 30)
        view.addSubview(previousButton)
        
        let nextButton = NSButton(title: "Next", target: self, action: #selector(nextSlide))
        nextButton.frame = NSRect(x: 550, y: 50, width: 100, height: 30)
        view.addSubview(nextButton)
    }
    
    private func loadSampleFile() {
        do {
            let path = "samples/sample1_SSI_Chap2.pptx"
            document = try PPTXDocument(filePath: path)
            updateSlideView()
        } catch {
            print("Failed to load file: \(error)")
        }
    }
    
    private func updateSlideView() {
        guard let document = document else { return }
        
        slideView = PPTXSlideView(document: document, slideIndex: currentSlideIndex, frame: slideView.frame)
        slideView.setNeedsRender()
    }
    
    @objc private func previousSlide() {
        if currentSlideIndex > 1 {
            currentSlideIndex -= 1
            updateSlideView()
        }
    }
    
    @objc private func nextSlide() {
        if let document = document,
           let count = try? document.getSlideCount(),
           currentSlideIndex < count {
            currentSlideIndex += 1
            updateSlideView()
        }
    }
}
#endif