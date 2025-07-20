#!/usr/bin/env swift

import Foundation

// Script to generate a multi-platform Xcode project for iOS and macOS
// This creates a single project with multiple targets

let fileManager = FileManager.default
let currentPath = fileManager.currentDirectoryPath

// MARK: - Xcode Project Generator

func generateMultiplatformProject() {
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
        \(iosTargetID) /* \(projectName).app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = \(projectName).app; sourceTree = BUILT_PRODUCTS_DIR; };
        \(macosTargetID) /* \(projectName).app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = \(projectName).app; sourceTree = BUILT_PRODUCTS_DIR; };
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
                \(groupID) /* Shared */,
                \(iosGroupID) /* iOS */,
                \(macosGroupID) /* macOS */,
                \(projectID.dropLast(8))PRODUCTS /* Products */,
            );
            sourceTree = "<group>";
        };
        \(projectID.dropLast(8))PRODUCTS /* Products */ = {
            isa = PBXGroup;
            children = (
                \(iosTargetID) /* \(projectName).app */,
                \(macosTargetID) /* \(projectName).app */,
            );
            name = Products;
            sourceTree = "<group>";
        };
        \(groupID) /* Shared */ = {
            isa = PBXGroup;
            children = (
            );
            path = Shared;
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
        \(iosTargetID.dropLast(8))IOSTARGET /* \(projectName) (iOS) */ = {
            isa = PBXNativeTarget;
            buildConfigurationList = \(configListIOS) /* Build configuration list for PBXNativeTarget "\(projectName) (iOS)" */;
            buildPhases = (
                \(iosSourcesPhase) /* Sources */,
                \(iosFrameworksPhase) /* Frameworks */,
            );
            buildRules = (
            );
            dependencies = (
            );
            name = "\(projectName) (iOS)";
            packageProductDependencies = (
                \(packageProductIOS.dropLast(8))PRODUCT /* PPTXKit */,
            );
            productName = "\(projectName)";
            productReference = \(iosTargetID) /* \(projectName).app */;
            productType = "com.apple.product-type.application";
        };
        \(macosTargetID.dropLast(8))MACOSTARGET /* \(projectName) (macOS) */ = {
            isa = PBXNativeTarget;
            buildConfigurationList = \(configListMacOS) /* Build configuration list for PBXNativeTarget "\(projectName) (macOS)" */;
            buildPhases = (
                \(macosSourcesPhase) /* Sources */,
                \(macosFrameworksPhase) /* Frameworks */,
            );
            buildRules = (
            );
            dependencies = (
            );
            name = "\(projectName) (macOS)";
            packageProductDependencies = (
                \(packageProductMacOS.dropLast(8))PRODUCT /* PPTXKit */,
            );
            productName = "\(projectName)";
            productReference = \(macosTargetID) /* \(projectName).app */;
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
                \(packageRef) /* XCLocalSwiftPackageReference */,
            );
            productRefGroup = \(projectID.dropLast(8))PRODUCTS /* Products */;
            projectDirPath = "";
            projectRoot = "";
            targets = (
                \(iosTargetID.dropLast(8))IOSTARGET /* \(projectName) (iOS) */,
                \(macosTargetID.dropLast(8))MACOSTARGET /* \(projectName) (macOS) */,
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
                PRODUCT_NAME = "\(projectName)";
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
                PRODUCT_NAME = "\(projectName)";
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
                MACOSX_DEPLOYMENT_TARGET = 12.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "com.example.PPTXViewer";
                PRODUCT_NAME = "\(projectName)";
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
                MACOSX_DEPLOYMENT_TARGET = 12.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "com.example.PPTXViewer";
                PRODUCT_NAME = "\(projectName)";
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
        \(configListIOS) /* Build configuration list for PBXNativeTarget "\(projectName) (iOS)" */ = {
            isa = XCConfigurationList;
            buildConfigurations = (
                \(debugConfigIOS) /* Debug */,
                \(releaseConfigIOS) /* Release */,
            );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
        \(configListMacOS) /* Build configuration list for PBXNativeTarget "\(projectName) (macOS)" */ = {
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
        \(packageRef) /* XCLocalSwiftPackageReference */ = {
            isa = XCLocalSwiftPackageReference;
            relativePath = "..";
        };
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
        \(packageProductIOS.dropLast(8))PRODUCT /* PPTXKit */ = {
            isa = XCSwiftPackageProductDependency;
            package = \(packageRef) /* XCLocalSwiftPackageReference */;
            productName = PPTXKit;
        };
        \(packageProductMacOS.dropLast(8))PRODUCT /* PPTXKit */ = {
            isa = XCSwiftPackageProductDependency;
            package = \(packageRef) /* XCLocalSwiftPackageReference */;
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
    
    // Create xcscheme for multi-platform builds
    let schemesDir = "\(projectDir)/xcshareddata/xcschemes"
    try? fileManager.createDirectory(atPath: schemesDir, withIntermediateDirectories: true)
    
    let schemePath = "\(schemesDir)/\(projectName).xcscheme"
    let schemeContent = """
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "\(iosTargetID.dropLast(8))IOSTARGET"
               BuildableName = "\(projectName).app"
               BlueprintName = "\(projectName) (iOS)"
               ReferencedContainer = "container:\(projectName).xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "\(macosTargetID.dropLast(8))MACOSTARGET"
               BuildableName = "\(projectName).app"
               BlueprintName = "\(projectName) (macOS)"
               ReferencedContainer = "container:\(projectName).xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
</Scheme>
"""
    
    try? schemeContent.write(toFile: schemePath, atomically: true, encoding: .utf8)
    
    print("✅ Created \(projectName).xcodeproj with iOS and macOS targets")
}

// MARK: - Main Script

print("🚀 Generating multi-platform Xcode project for PPTX Viewer...")
print()

// Check if we're in the right directory
guard fileManager.fileExists(atPath: "\(currentPath)/PPTXViewer-iOS") else {
    print("❌ Error: Please run this script from the SampleApps directory")
    exit(1)
}

// Generate multi-platform project
generateMultiplatformProject()

print()
print("✅ Done! Multi-platform Xcode project has been created.")
print()
print("📝 Next steps:")
print("1. Open PPTXViewer.xcodeproj")
print("2. Wait for Swift Package Manager to resolve dependencies")
print("3. Select your target:")
print("   - PPTXViewer (iOS) for iPhone/iPad")
print("   - PPTXViewer (macOS) for Mac")
print("4. Select your development team in project settings")
print("5. Build and run!")
print()
print("💡 Tips:")
print("- Use the scheme selector to switch between iOS and macOS targets")
print("- Both targets share the same package dependency")
print("- Each platform has its own Info.plist and source files")