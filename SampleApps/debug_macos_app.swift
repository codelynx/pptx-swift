#!/usr/bin/env swift

import Foundation
import AppKit
import SwiftUI
import PPTXKit

// Create a simple debug window to test rendering
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var manager: PPTXManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create PPTXManager
        manager = PPTXManager()
        
        // Create content view
        let contentView = DebugContentView(manager: manager)
        
        // Create window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("Debug Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        // Load a test file if provided
        if CommandLine.arguments.count > 1 {
            let filePath = CommandLine.arguments[1]
            loadFile(filePath)
        }
    }
    
    func loadFile(_ path: String) {
        print("📂 Loading file: \(path)")
        do {
            try manager.loadPresentation(from: path)
            print("✅ Loaded successfully")
            print("   Slides: \(manager.slideCount)")
            print("   Current slide: \(manager.currentSlideIndex)")
            
            if let slide = manager.currentSlide {
                print("   Current slide details:")
                print("     - ID: \(slide.id)")
                print("     - Title: \(slide.title ?? "No title")")
                print("     - Text content: \(slide.textContent.count) items")
                print("     - Shape count: \(slide.shapeCount)")
            } else {
                print("❌ Current slide is nil!")
            }
        } catch {
            print("❌ Error loading file: \(error)")
        }
    }
}

struct DebugContentView: View {
    @ObservedObject var manager: PPTXManager
    @State private var showingFilePicker = false
    
    var body: some View {
        VStack {
            if manager.slideCount > 0 {
                Text("Slides loaded: \(manager.slideCount)")
                Text("Current slide: \(manager.currentSlideIndex)")
                
                if let slide = manager.currentSlide {
                    Text("Slide title: \(slide.title ?? "No title")")
                    
                    PPTXSlideViewUI(slide: slide)
                        .renderingQuality(.high)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .padding()
                } else {
                    Text("⚠️ Current slide is nil")
                        .foregroundColor(.red)
                }
                
                HStack {
                    Button("Previous") { manager.goToPrevious() }
                        .disabled(!manager.canGoPrevious)
                    
                    Button("Next") { manager.goToNext() }
                        .disabled(!manager.canGoNext)
                }
                .padding()
            } else {
                VStack {
                    Text("No presentation loaded")
                    Button("Open File") {
                        showingFilePicker = true
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result,
               let url = urls.first {
                let delegate = NSApplication.shared.delegate as? AppDelegate
                delegate?.loadFile(url.path)
            }
        }
    }
}

// Create and run the app
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()