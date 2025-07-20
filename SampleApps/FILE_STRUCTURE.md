# Sample Apps File Structure

## What's Included

```
SampleApps/
├── PPTXViewer.xcodeproj/        # Multi-platform Xcode project
│   └── project.pbxproj          # Project configuration
│
├── PPTXViewer-iOS/              # iOS app source files
│   ├── PPTXViewerApp.swift      # App entry point (@main)
│   ├── ContentView.swift        # Main UI with tabs
│   └── Info.plist              # App configuration
│
├── PPTXViewer-macOS/            # macOS app source files
│   ├── PPTXViewerApp.swift      # App entry point (@main)
│   ├── ContentView.swift        # Split view UI
│   └── Info.plist              # App configuration
│
├── generate_multiplatform_project.swift  # Script to generate Xcode project
├── .gitignore                   # Git ignore patterns
│
├── README.md                    # Overview and features
├── QUICK_START.md              # 2-minute setup guide ⭐
├── XCODE_SETUP.md              # Detailed Xcode instructions
├── FILE_STRUCTURE.md           # This file
└── SAMPLE_APPS_SUMMARY.md      # Complete summary of sample apps
```

## About the Xcode Project

The included `PPTXViewer.xcodeproj` is a generated multi-platform project that:
- ✅ Contains both iOS and macOS targets
- ✅ References PPTXKit as a local package
- ✅ Has proper build settings for each platform
- ✅ Excludes user-specific settings (xcuserdata)

You can regenerate it anytime using:
```bash
swift generate_multiplatform_project.swift
```

## How to Use These Files

### Quick Method (Recommended) ⭐

1. Create new Xcode project
2. Add PPTXKit package dependency
3. Drag and drop our source files
4. Run!

See [QUICK_START.md](QUICK_START.md) for step-by-step instructions.

### What Each File Does

#### PPTXViewerApp.swift
- The `@main` entry point
- Sets up the app window
- Configures scenes (iOS) or window groups (macOS)

#### ContentView.swift
- Main user interface
- **iOS**: Tab view with presentation, thumbnails, and info
- **macOS**: Split view with sidebar and content area

#### Info.plist
- App configuration and permissions
- Document type associations (handles .pptx files)
- Required capabilities

## Customization Tips

Feel free to:
- ✏️ Modify the UI layout
- 🎨 Change colors and styling  
- ➕ Add new features
- 🔧 Adjust settings

The sample code is a starting point - make it your own!

## Questions?

- See [QUICK_START.md](QUICK_START.md) for setup help
- Check [XCODE_SETUP.md](XCODE_SETUP.md) for detailed instructions
- Review the main [PPTXKit documentation](../docs/API_REFERENCE.md)