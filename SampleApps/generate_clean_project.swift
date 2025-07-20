#!/usr/bin/env swift
import Foundation

// Script to generate a clean multi-platform Xcode project
// This creates a single project with iOS and macOS targets only

let fileManager = FileManager.default
let currentPath = fileManager.currentDirectoryPath

// MARK: - Xcode Project Generator

func generateCleanMultiplatformProject() {
    let projectName = "PPTXViewer"
    let projectDir = "\(currentPath)/\(projectName).xcodeproj"
    let pbxprojPath = "\(projectDir)/project.pbxproj"
    
    // Create project directory
    try? fileManager.createDirectory(atPath: projectDir, withIntermediateDirectories: true)
    
    // Generate UUIDs
    let projectID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let iosTargetID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let macosTargetID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let groupID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let iosGroupID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let macosGroupID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    // Build files
    let iosBuildFile1 = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let iosBuildFile2 = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let macosBuildFile1 = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let macosBuildFile2 = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    // File references
    let iosFileRef1 = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let iosFileRef2 = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let macosFileRef1 = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let macosFileRef2 = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    // Build phases
    let iosFrameworksPhase = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let iosSourcesPhase = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let macosFrameworksPhase = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let macosSourcesPhase = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    // Config lists
    let configListProject = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let configListIOS = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let configListMacOS = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    // Configurations
    let debugConfig = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let releaseConfig = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let debugConfigIOS = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let releaseConfigIOS = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let debugConfigMacOS = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let releaseConfigMacOS = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    // Package references
    let packageRef = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let packageProductIOS = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let packageProductMacOS = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    let projectContent = """
// !$*UTF8*$!
{
    archiveVersion = 1;
    classes = {
    };
    objectVersion = 56;
    objects = {

/* Begin PBXBuildFile section */
        \(iosBuildFile1) /* PPTXViewerApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = \(iosFileRef1) /* PPTXViewerApp.swift */; };
        \(iosBuildFile2) /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = \(iosFileRef2) /* ContentView.swift */; };
        \(macosBuildFile1) /* PPTXViewerApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = \(macosFileRef1) /* PPTXViewerApp.swift */; };
        \(macosBuildFile2) /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = \(macosFileRef2) /* ContentView.swift */; };
        \(packageProductIOS) /* PPTXKit in Frameworks */ = {isa = PBXBuildFile; productRef = \(packageProductIOS.dropLast(8))PRODUCT /* PPTXKit */; };
        \(packageProductMacOS) /* PPTXKit in Frameworks */ = {isa = PBXBuildFile; productRef = \(packageProductMacOS.dropLast(8))PRODUCT /* PPTXKit */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
        \(iosTargetID) /* PPTXViewer.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = PPTXViewer.app; sourceTree = BUILT_PRODUCTS_DIR; };
        \(macosTargetID) /* PPTXViewer.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = PPTXViewer.app; sourceTree = BUILT_PRODUCTS_DIR; };
        \(iosFileRef1) /* PPTXViewerApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PPTXViewerApp.swift; sourceTree = "<group>"; };
        \(iosFileRef2) /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
        \(macosFileRef1) /* PPTXViewerApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PPTXViewerApp.swift; sourceTree = "<group>"; };
        \(macosFileRef2) /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
        \(iosFrameworksPhase) /* Frameworks */ = {
            isa = PBXFrameworksBuildPhase;
            buildActionMask = 2147483647;
            files = (
                \(packageProductIOS) /* PPTXKit in Frameworks */,
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
        \(macosFrameworksPhase) /* Frameworks */ = {
            isa = PBXFrameworksBuildPhase;
            buildActionMask = 2147483647;
            files = (
                \(packageProductMacOS) /* PPTXKit in Frameworks */,
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
        \(projectID) = {
            isa = PBXGroup;
            children = (
                \(iosGroupID) /* iOS */,
                \(macosGroupID) /* macOS */,
                \(projectID.dropLast(8))PRODUCTS /* Products */,
            );
            sourceTree = "<group>";
        };
        \(projectID.dropLast(8))PRODUCTS /* Products */ = {
            isa = PBXGroup;
            children = (
                \(iosTargetID) /* PPTXViewer.app */,
                \(macosTargetID) /* PPTXViewer.app */,
            );
            name = Products;
            sourceTree = "<group>";
        };
        \(iosGroupID) /* iOS */ = {
            isa = PBXGroup;
            children = (
                \(iosFileRef1) /* PPTXViewerApp.swift */,
                \(iosFileRef2) /* ContentView.swift */,
            );
            path = "PPTXViewer-iOS";
            sourceTree = "<group>";
        };
        \(macosGroupID) /* macOS */ = {
            isa = PBXGroup;
            children = (
                \(macosFileRef1) /* PPTXViewerApp.swift */,
                \(macosFileRef2) /* ContentView.swift */,
            );
            path = "PPTXViewer-macOS";
            sourceTree = "<group>";
        };
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
        \(iosTargetID.dropLast(8))IOSTARGET /* PPTXViewer (iOS) */ = {
            isa = PBXNativeTarget;
            buildConfigurationList = \(configListIOS) /* Build configuration list for PBXNativeTarget "PPTXViewer (iOS)" */;
            buildPhases = (
                \(iosSourcesPhase) /* Sources */,
                \(iosFrameworksPhase) /* Frameworks */,
            );
            buildRules = (
            );
            dependencies = (
            );
            name = "PPTXViewer (iOS)";
            packageProductDependencies = (
                \(packageProductIOS.dropLast(8))PRODUCT /* PPTXKit */,
            );
            productName = "PPTXViewer";
            productReference = \(iosTargetID) /* PPTXViewer.app */;
            productType = "com.apple.product-type.application";
        };
        \(macosTargetID.dropLast(8))MACOSTARGET /* PPTXViewer (macOS) */ = {
            isa = PBXNativeTarget;
            buildConfigurationList = \(configListMacOS) /* Build configuration list for PBXNativeTarget "PPTXViewer (macOS)" */;
            buildPhases = (
                \(macosSourcesPhase) /* Sources */,
                \(macosFrameworksPhase) /* Frameworks */,
            );
            buildRules = (
            );
            dependencies = (
            );
            name = "PPTXViewer (macOS)";
            packageProductDependencies = (
                \(packageProductMacOS.dropLast(8))PRODUCT /* PPTXKit */,
            );
            productName = "PPTXViewer";
            productReference = \(macosTargetID) /* PPTXViewer.app */;
            productType = "com.apple.product-type.application";
        };
/* End PBXNativeTarget section */

/* Begin PBXProject section */
        \(projectID.dropLast(8))PROJECT /* Project object */ = {
            isa = PBXProject;
            attributes = {
                BuildIndependentTargetsInParallel = 1;
                LastSwiftUpdateCheck = 1500;
                LastUpgradeCheck = 1500;
            };
            buildConfigurationList = \(configListProject) /* Build configuration list for PBXProject "\(projectName)" */;
            compatibilityVersion = "Xcode 14.0";
            developmentRegion = en;
            hasScannedForEncodings = 0;
            knownRegions = (
                en,
                Base,
            );
            mainGroup = \(projectID);
            packageReferences = (
                \(packageRef) /* XCLocalSwiftPackageReference "../" */,
            );
            productRefGroup = \(projectID.dropLast(8))PRODUCTS /* Products */;
            projectDirPath = "";
            projectRoot = "";
            targets = (
                \(iosTargetID.dropLast(8))IOSTARGET /* PPTXViewer (iOS) */,
                \(macosTargetID.dropLast(8))MACOSTARGET /* PPTXViewer (macOS) */,
            );
        };
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
        \(iosSourcesPhase) /* Sources */ = {
            isa = PBXSourcesBuildPhase;
            buildActionMask = 2147483647;
            files = (
                \(iosBuildFile1) /* PPTXViewerApp.swift in Sources */,
                \(iosBuildFile2) /* ContentView.swift in Sources */,
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
        \(macosSourcesPhase) /* Sources */ = {
            isa = PBXSourcesBuildPhase;
            buildActionMask = 2147483647;
            files = (
                \(macosBuildFile1) /* PPTXViewerApp.swift in Sources */,
                \(macosBuildFile2) /* ContentView.swift in Sources */,
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
        \(debugConfig) /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                CLANG_ANALYZER_NONNULL = YES;
                CLANG_ENABLE_MODULES = YES;
                CLANG_ENABLE_OBJC_ARC = YES;
                DEBUG_INFORMATION_FORMAT = dwarf;
                ENABLE_STRICT_OBJC_MSGSEND = YES;
                GCC_C_LANGUAGE_STANDARD = gnu11;
                GCC_NO_COMMON_BLOCKS = YES;
                GCC_OPTIMIZATION_LEVEL = 0;
                MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
                MTL_FAST_MATH = YES;
                ONLY_ACTIVE_ARCH = YES;
                SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
                SWIFT_VERSION = 5.0;
            };
            name = Debug;
        };
        \(releaseConfig) /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                CLANG_ANALYZER_NONNULL = YES;
                CLANG_ENABLE_MODULES = YES;
                CLANG_ENABLE_OBJC_ARC = YES;
                DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
                ENABLE_NS_ASSERTIONS = NO;
                ENABLE_STRICT_OBJC_MSGSEND = YES;
                GCC_C_LANGUAGE_STANDARD = gnu11;
                GCC_NO_COMMON_BLOCKS = YES;
                MTL_ENABLE_DEBUG_INFO = NO;
                MTL_FAST_MATH = YES;
                SWIFT_COMPILATION_MODE = wholemodule;
                SWIFT_OPTIMIZATION_LEVEL = "-O";
                SWIFT_VERSION = 5.0;
            };
            name = Release;
        };
        \(debugConfigIOS) /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                ENABLE_PREVIEWS = YES;
                GENERATE_INFOPLIST_FILE = YES;
                INFOPLIST_FILE = "PPTXViewer-iOS/Info.plist";
                IPHONEOS_DEPLOYMENT_TARGET = 16.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "com.example.PPTXViewer";
                PRODUCT_NAME = "PPTXViewer";
                SDKROOT = iphoneos;
                SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
                SWIFT_EMIT_LOC_STRINGS = YES;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Debug;
        };
        \(releaseConfigIOS) /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                ENABLE_PREVIEWS = YES;
                GENERATE_INFOPLIST_FILE = YES;
                INFOPLIST_FILE = "PPTXViewer-iOS/Info.plist";
                IPHONEOS_DEPLOYMENT_TARGET = 16.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "com.example.PPTXViewer";
                PRODUCT_NAME = "PPTXViewer";
                SDKROOT = iphoneos;
                SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
                SWIFT_EMIT_LOC_STRINGS = YES;
                TARGETED_DEVICE_FAMILY = "1,2";
                VALIDATE_PRODUCT = YES;
            };
            name = Release;
        };
        \(debugConfigMacOS) /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                CODE_SIGN_STYLE = Automatic;
                COMBINE_HIDPI_IMAGES = YES;
                CURRENT_PROJECT_VERSION = 1;
                ENABLE_PREVIEWS = YES;
                GENERATE_INFOPLIST_FILE = YES;
                INFOPLIST_FILE = "PPTXViewer-macOS/Info.plist";
                MACOSX_DEPLOYMENT_TARGET = 13.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "com.example.PPTXViewer";
                PRODUCT_NAME = "PPTXViewer";
                SDKROOT = macosx;
                SWIFT_EMIT_LOC_STRINGS = YES;
            };
            name = Debug;
        };
        \(releaseConfigMacOS) /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                CODE_SIGN_STYLE = Automatic;
                COMBINE_HIDPI_IMAGES = YES;
                CURRENT_PROJECT_VERSION = 1;
                ENABLE_PREVIEWS = YES;
                GENERATE_INFOPLIST_FILE = YES;
                INFOPLIST_FILE = "PPTXViewer-macOS/Info.plist";
                MACOSX_DEPLOYMENT_TARGET = 13.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "com.example.PPTXViewer";
                PRODUCT_NAME = "PPTXViewer";
                SDKROOT = macosx;
                SWIFT_EMIT_LOC_STRINGS = YES;
            };
            name = Release;
        };
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
        \(configListProject) /* Build configuration list for PBXProject "\(projectName)" */ = {
            isa = XCConfigurationList;
            buildConfigurations = (
                \(debugConfig) /* Debug */,
                \(releaseConfig) /* Release */,
            );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
        \(configListIOS) /* Build configuration list for PBXNativeTarget "PPTXViewer (iOS)" */ = {
            isa = XCConfigurationList;
            buildConfigurations = (
                \(debugConfigIOS) /* Debug */,
                \(releaseConfigIOS) /* Release */,
            );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
        \(configListMacOS) /* Build configuration list for PBXNativeTarget "PPTXViewer (macOS)" */ = {
            isa = XCConfigurationList;
            buildConfigurations = (
                \(debugConfigMacOS) /* Debug */,
                \(releaseConfigMacOS) /* Release */,
            );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
/* End XCConfigurationList section */

/* Begin XCLocalSwiftPackageReference section */
        \(packageRef) /* XCLocalSwiftPackageReference "../" */ = {
            isa = XCLocalSwiftPackageReference;
            relativePath = ..;
        };
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
        \(packageProductIOS.dropLast(8))PRODUCT /* PPTXKit */ = {
            isa = XCSwiftPackageProductDependency;
            package = \(packageRef) /* XCLocalSwiftPackageReference "../" */;
            productName = PPTXKit;
        };
        \(packageProductMacOS.dropLast(8))PRODUCT /* PPTXKit */ = {
            isa = XCSwiftPackageProductDependency;
            package = \(packageRef) /* XCLocalSwiftPackageReference "../" */;
            productName = PPTXKit;
        };
/* End XCSwiftPackageProductDependency section */
    };
    rootObject = \(projectID.dropLast(8))PROJECT /* Project object */;
}
"""
    
    // Write project file
    try? projectContent.write(toFile: pbxprojPath, atomically: true, encoding: .utf8)
    
    // Create xcworkspace for package resolution
    let workspaceDir = "\(currentPath)/\(projectName).xcworkspace"
    let workspaceDataPath = "\(workspaceDir)/contents.xcworkspacedata"
    try? fileManager.createDirectory(atPath: workspaceDir, withIntermediateDirectories: true)
    
    let workspaceContent = """
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""
    
    try? workspaceContent.write(toFile: workspaceDataPath, atomically: true, encoding: .utf8)
    
    print("✅ Created clean \(projectName).xcodeproj with only iOS and macOS app targets")
}

// MARK: - Main Script

print("🧹 Generating clean Xcode project with only app targets...")
print()

// Check if we're in the right directory
guard fileManager.fileExists(atPath: "\(currentPath)/PPTXViewer-iOS") else {
    print("❌ Error: Please run this script from the SampleApps directory")
    exit(1)
}

// Remove old project
if fileManager.fileExists(atPath: "\(currentPath)/PPTXViewer.xcodeproj") {
    try? fileManager.removeItem(atPath: "\(currentPath)/PPTXViewer.xcodeproj")
    print("🗑️  Removed old project")
}

// Generate clean multi-platform project
generateCleanMultiplatformProject()

print()
print("✅ Done! Clean Xcode project has been created.")
print()
print("📝 What's different:")
print("- Only contains PPTXViewer (iOS) and PPTXViewer (macOS) targets")
print("- PPTXKit is referenced as a package dependency, not a target")
print("- No duplicate PPTXViewer target")
print("- Cleaner project structure")
print()
print("🚀 Next steps:")
print("1. Open PPTXViewer.xcodeproj")
print("2. Select your target: iOS or macOS")
print("3. Build and run!")