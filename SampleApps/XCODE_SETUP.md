# Xcode Setup Guide for PPTX Viewer Apps

This guide will help you set up the sample apps in Xcode.

## Option 1: Create New Xcode Projects (Recommended)

### For iOS App:

1. **Open Xcode** and create a new project:
   - Choose **iOS** → **App**
   - Product Name: `PPTXViewer`
   - Team: Select your development team
   - Organization Identifier: `com.yourcompany`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Use Core Data: No
   - Include Tests: Yes (optional)

2. **Add PPTXKit Package:**
   - Select your project in the navigator
   - Select the `PPTXViewer` target
   - Go to **General** → **Frameworks, Libraries, and Embedded Content**
   - Click **+** → **Add Package Dependency**
   - Click **Add Local** and navigate to the `pptx-swift` directory
   - Select **PPTXKit** library when prompted

3. **Replace the generated files:**
   - Delete the default `ContentView.swift`
   - Drag and drop `ContentView.swift` from `SampleApps/PPTXViewer-iOS/`
   - Replace `PPTXViewerApp.swift` content with the sample version
   - Replace `Info.plist` with the sample version

4. **Configure signing:**
   - Select your target
   - Go to **Signing & Capabilities**
   - Select your team
   - Xcode will manage provisioning profiles

5. **Build and run:**
   - Select a simulator or device
   - Press **Cmd+R**

### For macOS App:

1. **Create new macOS project:**
   - Choose **macOS** → **App**
   - Follow similar steps as iOS
   - Deployment Target: macOS 12.0

2. **Add the same PPTXKit package dependency**

3. **Replace files with macOS versions from `SampleApps/PPTXViewer-macOS/`**

4. **Enable file access:**
   - Go to **Signing & Capabilities**
   - Add **App Sandbox** capability (if not present)
   - Check **User Selected File** → **Read**

## Option 2: Use Swift Package Manager

### Generate Xcode Projects:

```bash
cd SampleApps
./create_xcode_projects.sh
```

This will create `.xcodeproj` files for both apps.

### Open in Xcode:

```bash
# iOS
open PPTXViewer-iOS/PPTXViewer-iOS.xcodeproj

# macOS
open PPTXViewer-macOS/PPTXViewer-macOS.xcodeproj
```

## Common Setup Tasks

### iOS Specific:

1. **Enable Document Browser:**
   - Already configured in Info.plist
   - Allows users to browse and open PPTX files

2. **iPad Support:**
   - The app is universal and supports iPad
   - Test on different screen sizes

### macOS Specific:

1. **File Associations:**
   - The app registers as a viewer for .pptx files
   - Users can right-click → Open With → PPTXViewer

2. **Menu Bar:**
   - File → Open is connected to the file picker
   - Standard keyboard shortcuts work

## Testing

### Test Files:
- Use the sample PPTX files in `samples/` directory
- Test with your own PowerPoint files
- Try files with different layouts and content

### Features to Test:
1. Opening files
2. Navigation (swipe, buttons, keyboard)
3. Thumbnail view
4. Search functionality (macOS)
5. Window resizing (macOS)
6. Device rotation (iOS)

## Troubleshooting

### "No such module 'PPTXKit'"
- Ensure the package dependency is correctly added
- Clean build folder: **Cmd+Shift+K**
- Reset package caches: **File** → **Packages** → **Reset Package Caches**

### File Access Issues:
- iOS: Ensure document browser entitlements are set
- macOS: Check sandbox permissions for file read access

### Build Errors:
- Minimum deployment targets: iOS 14.0, macOS 12.0
- Swift version: 5.9 or later
- Update Xcode if needed

## Customization Ideas

1. **Add App Icons:**
   - Create icon sets for both platforms
   - Use SF Symbols for toolbar icons

2. **Enhance UI:**
   - Add themes/color schemes
   - Implement slide transitions
   - Add presenter notes view

3. **Additional Features:**
   - Export slides as images
   - Print support
   - Share functionality
   - Recent files list

## Distribution

### iOS:
1. Archive the app: **Product** → **Archive**
2. Distribute via TestFlight or App Store
3. Or export for Ad Hoc distribution

### macOS:
1. Archive the app
2. Notarize for distribution outside App Store
3. Or distribute via Mac App Store

## Resources

- [PPTXKit Documentation](../docs/API_REFERENCE.md)
- [Apple's SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Document Browser Documentation](https://developer.apple.com/documentation/uikit/uidocumentbrowserviewcontroller)