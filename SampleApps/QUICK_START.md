# Quick Start Guide - PPTX Viewer Sample Apps

## The Fastest Way to Get Started

### Option 1: Use the Generated Projects (30 seconds) ⚡

#### Multi-platform Project (Recommended)
```bash
# From the SampleApps directory
swift generate_multiplatform_project.swift

# Open in Xcode
open PPTXViewer.xcodeproj
```

This creates a single project with both iOS and macOS targets!

#### Separate Projects
```bash
# Generate separate iOS and macOS projects
swift generate_projects.swift

# Open in Xcode
open PPTXViewer-iOS.xcodeproj    # or
open PPTXViewer-macOS.xcodeproj
```

That's it! The script creates properly configured Xcode projects with:
- ✅ PPTXKit package dependency already added
- ✅ All source files in place
- ✅ Info.plist configured
- ✅ Ready to build and run

Just select your team and run!

### Option 2: Create Your Own Project (2 minutes)

## iOS App (2 minutes)

1. **Open Xcode** → **Create New Project**
   - Platform: **iOS**
   - Template: **App**
   - Product Name: **PPTXViewer**
   - Interface: **SwiftUI**
   - Language: **Swift**

2. **Add PPTXKit Package**
   - File → Add Package Dependencies
   - Click "Add Local..."
   - Navigate to the `pptx-swift` folder
   - Click "Add Package"
   - Select "PPTXKit" library → "Add Package"

3. **Replace the Files**
   - In Finder, navigate to `SampleApps/PPTXViewer-iOS/`
   - Drag `ContentView.swift` into Xcode (replace existing)
   - In `PPTXViewerApp.swift`, replace all content with the sample version

4. **Update Info.plist**
   - Select your project → Target → Info
   - Add "Supports Document Browser" = YES
   - Add "Supports Opening Documents In Place" = YES

5. **Run!** Press Cmd+R

## macOS App (2 minutes)

1. **Open Xcode** → **Create New Project**
   - Platform: **macOS**
   - Template: **App**
   - Same settings as iOS

2. **Add PPTXKit Package** (same as iOS)

3. **Replace Files**
   - Use files from `SampleApps/PPTXViewer-macOS/`

4. **Run!** Press Cmd+R

## What You Get

### iOS App Features:
- ✅ Open PPTX files from Files app
- ✅ Swipe between slides
- ✅ Thumbnail grid view
- ✅ Presentation info
- ✅ Works on iPhone & iPad

### macOS App Features:
- ✅ Native Mac app with menu bar
- ✅ Split view with sidebar
- ✅ Keyboard navigation
- ✅ Search slides
- ✅ Multiple view modes

## Alternative: Command Line Setup

If you prefer using Swift Package Manager:

```bash
cd SampleApps/PPTXViewer-iOS
swift run  # Won't work for iOS apps

# Generate Xcode project
swift package generate-xcodeproj
open PPTXViewer-iOS.xcodeproj
```

But the manual Xcode method above is recommended for iOS/macOS apps.

## Troubleshooting

### "No such module 'PPTXKit'"
- Make sure you added the package dependency
- Clean build folder (Cmd+Shift+K)

### Can't open PPTX files
- Check Info.plist settings
- Ensure document types are configured

### Build errors
- Check minimum deployment target (iOS 14.0, macOS 12.0)
- Verify Swift version (5.9+)

## Next Steps

Once you have the app running:
1. Try opening different PPTX files
2. Customize the UI
3. Add your own features
4. Check out the [full documentation](README.md)

---

💡 **Pro tip**: The sample code is meant to be a starting point. Feel free to modify and extend it for your needs!