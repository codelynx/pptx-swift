import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A complete presentation view with navigation controls
public struct PPTXPresentationView: View {
    @ObservedObject private var manager: PPTXManager
    
    // Customization options
    private var showNavigationControls: Bool = true
    private var showSlideCounter: Bool = true
    private var showProgressBar: Bool = true
    private var renderingQuality: RenderingQuality = .balanced
    private var backgroundColor: Color = {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }()
    
    // Navigation actions
    private var onSlideChange: ((Int) -> Void)?
    private var onError: ((Error) -> Void)?
    
    public init(manager: PPTXManager) {
        self.manager = manager
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            if showProgressBar {
                ProgressView(value: manager.progress)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            
            // Main content
            ZStack {
                // Background
                backgroundColor
                
                // Slide view
                if manager.currentSlide != nil, let document = manager.document {
                    PPTXSlideViewUI(document: document, slideIndex: manager.currentSlideIndex)
                        .renderingQuality(renderingQuality)
                        .padding()
                } else if manager.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = manager.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error loading presentation")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    Text("No presentation loaded")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Navigation controls
            if showNavigationControls {
                navigationBar
            }
        }
        .onChange(of: manager.currentSlideIndex) { newIndex in
            onSlideChange?(newIndex)
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: 20) {
            // Previous button
            Button(action: { manager.goToPrevious() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            .disabled(!manager.canGoPrevious)
            .keyboardShortcut(.leftArrow, modifiers: [])
            
            // Slide counter
            if showSlideCounter {
                Text("\(manager.currentSlideIndex) / \(manager.slideCount)")
                    .font(.headline)
                    .frame(minWidth: 80)
            }
            
            // Next button
            Button(action: { manager.goToNext() }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
            .disabled(!manager.canGoNext)
            .keyboardShortcut(.rightArrow, modifiers: [])
            
            Spacer()
            
            // Additional controls
            Menu {
                Button("First Slide") {
                    manager.goToFirst()
                }
                .keyboardShortcut(.home, modifiers: [])
                
                Button("Last Slide") {
                    manager.goToLast()
                }
                .keyboardShortcut(.end, modifiers: [])
                
                Divider()
                
                Menu("Go to Slide") {
                    ForEach(1...manager.slideCount, id: \.self) { index in
                        Button("Slide \(index)") {
                            manager.goToSlide(at: index)
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
            }
        }
        .padding()
        .background({
            #if os(iOS)
            return Color(UIColor.systemGray6)
            #else
            return Color(NSColor.controlBackgroundColor)
            #endif
        }())
    }
}

// MARK: - View Modifiers

extension PPTXPresentationView {
    /// Show or hide navigation controls
    public func navigationControlsVisible(_ visible: Bool) -> PPTXPresentationView {
        var view = self
        view.showNavigationControls = visible
        return view
    }
    
    /// Show or hide slide counter
    public func slideCounterVisible(_ visible: Bool) -> PPTXPresentationView {
        var view = self
        view.showSlideCounter = visible
        return view
    }
    
    /// Show or hide progress bar
    public func progressBarVisible(_ visible: Bool) -> PPTXPresentationView {
        var view = self
        view.showProgressBar = visible
        return view
    }
    
    /// Set rendering quality
    public func renderingQuality(_ quality: RenderingQuality) -> PPTXPresentationView {
        var view = self
        view.renderingQuality = quality
        return view
    }
    
    /// Set background color
    public func backgroundColor(_ color: Color) -> PPTXPresentationView {
        var view = self
        view.backgroundColor = color
        return view
    }
    
    /// Set slide change handler
    public func onSlideChange(_ handler: @escaping (Int) -> Void) -> PPTXPresentationView {
        var view = self
        view.onSlideChange = handler
        return view
    }
    
    /// Set error handler
    public func onError(_ handler: @escaping (Error) -> Void) -> PPTXPresentationView {
        var view = self
        view.onError = handler
        return view
    }
}

// MARK: - Thumbnail Grid View

/// A grid view showing all slides as thumbnails
public struct PPTXThumbnailGridView: View {
    @ObservedObject private var manager: PPTXManager
    private let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 16)
    ]
    
    public init(manager: PPTXManager) {
        self.manager = manager
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(manager.allSlides().enumerated()), id: \.element.id) { index, slide in
                    ThumbnailView(
                        slide: slide,
                        document: manager.document,
                        index: index + 1,
                        isSelected: manager.currentSlideIndex == index + 1
                    ) {
                        manager.goToSlide(at: index + 1)
                    }
                }
            }
            .padding()
        }
    }
    
    private struct ThumbnailView: View {
        let slide: Slide
        let document: PPTXDocument?
        let index: Int
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 8) {
                    // Slide preview
                    Group {
                        if let document = document {
                            PPTXSlideViewUI(document: document, slideIndex: index)
                                .renderingQuality(.low)
                        } else {
                            PPTXSlideViewUI(slide: slide)
                                .renderingQuality(.low)
                        }
                    }
                        .frame(height: 150)
                        .background({
            #if os(iOS)
            return Color(UIColor.systemGray6)
            #else
            return Color(NSColor.controlBackgroundColor)
            #endif
        }())
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                        )
                    
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