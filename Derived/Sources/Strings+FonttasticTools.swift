// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum FonttasticToolsStrings {

  public enum FontListCollection {
    public enum BannerTitle {
      /// Tap here to add\nFonttastic keyboard to iOS ⌨️
      public static let keyboardInstall = FonttasticToolsStrings.tr("Localizable", "fontListCollection.bannerTitle.keyboardInstall")
      /// Tap here\nto get Premium 🦹‍♂️
      public static let subscriptionPurchase = FonttasticToolsStrings.tr("Localizable", "fontListCollection.bannerTitle.subscriptionPurchase")
    }
    public enum SectionHeader {
      /// Custom fonts
      public static let customFonts = FonttasticToolsStrings.tr("Localizable", "fontListCollection.sectionHeader.customFonts")
      /// System fonts
      public static let systemFonts = FonttasticToolsStrings.tr("Localizable", "fontListCollection.sectionHeader.systemFonts")
    }
  }

  public enum FontSelection {
    /// Font
    public static let title = FonttasticToolsStrings.tr("Localizable", "fontSelection.title")
    public enum Prompt {
      /// Cyrillic fonts
      public static let cyrillicFonts = FonttasticToolsStrings.tr("Localizable", "fontSelection.prompt.cyrillicFonts")
      /// Latin fonts
      public static let latinFonts = FonttasticToolsStrings.tr("Localizable", "fontSelection.prompt.latinFonts")
    }
  }

  public enum Keyboard {
    public enum Canvas {
      public enum Copied {
        /// ✅ Copied
        public static let title = FonttasticToolsStrings.tr("Localizable", "keyboard.canvas.copied.title")
      }
    }
    public enum LockedState {
      /// Keyboard is locked
      public static let title = FonttasticToolsStrings.tr("Localizable", "keyboard.lockedState.title")
      public enum LimitedAccess {
        /// Open Settings
        public static let actionTitle = FonttasticToolsStrings.tr("Localizable", "keyboard.lockedState.limitedAccess.actionTitle")
        /// To use keyboard, please open settings and enable keyboard full access
        public static let message = FonttasticToolsStrings.tr("Localizable", "keyboard.lockedState.limitedAccess.message")
      }
      public enum NoSubscription {
        /// Open App
        public static let actionTitle = FonttasticToolsStrings.tr("Localizable", "keyboard.lockedState.noSubscription.actionTitle")
        /// To use keyboard, please open app and purchase subscription
        public static let message = FonttasticToolsStrings.tr("Localizable", "keyboard.lockedState.noSubscription.message")
      }
    }
  }

  public enum Subscription {
    public enum Button {
      public enum Title {
        /// Subscribe
        public static let `default` = FonttasticToolsStrings.tr("Localizable", "subscription.button.title.default")
        /// Start free trial
        public static let trial = FonttasticToolsStrings.tr("Localizable", "subscription.button.title.trial")
      }
    }
    public enum Header {
      /// And start using custom fonts anywhere
      public static let subtitle = FonttasticToolsStrings.tr("Localizable", "subscription.header.subtitle")
      public enum Title {
        /// Get Premium access to Fonttastic Keyboard
        public static let `default` = FonttasticToolsStrings.tr("Localizable", "subscription.header.title.default")
        /// Start Premium access free trial
        public static let trial = FonttasticToolsStrings.tr("Localizable", "subscription.header.title.trial")
      }
    }
    public enum Info {
      public enum Active {
        ///  Subscription will expire at %@
        public static func expirationDate(_ p1: Any) -> String {
          return FonttasticToolsStrings.tr("Localizable", "subscription.info.active.expirationDate", String(describing: p1))
        }
        ///  Subscription will renew at %@
        public static func renewDate(_ p1: Any) -> String {
          return FonttasticToolsStrings.tr("Localizable", "subscription.info.active.renewDate", String(describing: p1))
        }
        ///  since %@
        public static func since(_ p1: Any) -> String {
          return FonttasticToolsStrings.tr("Localizable", "subscription.info.active.since", String(describing: p1))
        }
        public enum FamilyShared {
          /// You have a family shared Premium membership 😎
          public static let title = FonttasticToolsStrings.tr("Localizable", "subscription.info.active.familyShared.title")
        }
        public enum FreeTrial {
          ///  with free trial until %@
          public static func withExpirationDate(_ p1: Any) -> String {
            return FonttasticToolsStrings.tr("Localizable", "subscription.info.active.freeTrial.withExpirationDate", String(describing: p1))
          }
          ///  with free trial.
          public static let withoutExpirationDate = FonttasticToolsStrings.tr("Localizable", "subscription.info.active.freeTrial.withoutExpirationDate")
        }
        public enum Solo {
          /// Your are a Premium member 😎
          public static let title = FonttasticToolsStrings.tr("Localizable", "subscription.info.active.solo.title")
        }
      }
      public enum Inactive {
        ///  Please renew your subscription in order to use Fonttastic Keyboard.
        public static let callToAction = FonttasticToolsStrings.tr("Localizable", "subscription.info.inactive.callToAction")
        public enum FamilyShared {
          /// Your family shared Premium membership has expired
          public static let title = FonttasticToolsStrings.tr("Localizable", "subscription.info.inactive.familyShared.title")
        }
        public enum Solo {
          /// Your Premium membership has expired
          public static let title = FonttasticToolsStrings.tr("Localizable", "subscription.info.inactive.solo.title")
        }
        public enum TitleEnding {
          ///  😔.
          public static let noExpirationDate = FonttasticToolsStrings.tr("Localizable", "subscription.info.inactive.titleEnding.noExpirationDate")
          ///  at %@ 😔.
          public static func withExpirationDate(_ p1: Any) -> String {
            return FonttasticToolsStrings.tr("Localizable", "subscription.info.inactive.titleEnding.withExpirationDate", String(describing: p1))
          }
        }
      }
    }
    public enum Item {
      public enum Subtitle {
        public enum Trial {
          public enum Days {
            /// First 3 days free
            public static let _3 = FonttasticToolsStrings.tr("Localizable", "subscription.item.subtitle.trial.days.3")
          }
        }
      }
    }
    public enum Period {
      /// Annual
      public static let annual = FonttasticToolsStrings.tr("Localizable", "subscription.period.annual")
      /// Lifetime
      public static let lifetime = FonttasticToolsStrings.tr("Localizable", "subscription.period.lifetime")
      /// Monthly
      public static let monthly = FonttasticToolsStrings.tr("Localizable", "subscription.period.monthly")
      /// 6 Months
      public static let sixMonths = FonttasticToolsStrings.tr("Localizable", "subscription.period.sixMonths")
      /// 3 Months
      public static let threeMonths = FonttasticToolsStrings.tr("Localizable", "subscription.period.threeMonths")
      /// 2 Months
      public static let twoMonths = FonttasticToolsStrings.tr("Localizable", "subscription.period.twoMonths")
      /// Weekly
      public static let weekly = FonttasticToolsStrings.tr("Localizable", "subscription.period.weekly")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension FonttasticToolsStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = FonttasticToolsResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
