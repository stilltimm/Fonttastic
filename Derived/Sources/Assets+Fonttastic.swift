// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum FonttasticAsset {
  public static let accentColor = FonttasticColors(name: "AccentColor")
  public static let backgroundMain = FonttasticColors(name: "BackgroundMain")
  public static let blackAndWhite = FonttasticColors(name: "BlackAndWhite")
  public static let plusIcon = FonttasticImages(name: "PlusIcon")
  public static let background = FonttasticImages(name: "background")
  public static let keyboardProHeader = FonttasticImages(name: "keyboard-pro-header")
  public static let onboardingFirstPageHeading1 = FonttasticImages(name: "onboarding-first-page-heading-1")
  public static let onboardingFirstPageHeading2 = FonttasticImages(name: "onboarding-first-page-heading-2")
  public static let onboardingFirstPageHeading3 = FonttasticImages(name: "onboarding-first-page-heading-3")
  public static let onboardingFirstPageIphone = FonttasticImages(name: "onboarding-first-page-iphone")
  public static let onboardingFirstPageSmile1 = FonttasticImages(name: "onboarding-first-page-smile-1")
  public static let onboardingFirstPageSmile2 = FonttasticImages(name: "onboarding-first-page-smile-2")
  public static let onboardingFirstPageSmile3 = FonttasticImages(name: "onboarding-first-page-smile-3")
  public static let onboardingSecondPageCard = FonttasticImages(name: "onboarding-second-page-card")
  public static let onboardingSecondPageHeading1 = FonttasticImages(name: "onboarding-second-page-heading-1")
  public static let onboardingSecondPageHeading2 = FonttasticImages(name: "onboarding-second-page-heading-2")
  public static let onboardingSecondPageHeading3 = FonttasticImages(name: "onboarding-second-page-heading-3")
  public static let onboardingSecondPageLogo = FonttasticImages(name: "onboarding-second-page-logo")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class FonttasticColors {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension FonttasticColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: FonttasticColors) {
    let bundle = FonttasticResources.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct FonttasticImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = FonttasticResources.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

public extension FonttasticImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the FonttasticImages.image property")
  convenience init?(asset: FonttasticImages) {
    #if os(iOS) || os(tvOS)
    let bundle = FonttasticResources.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:enable all
// swiftformat:enable all
