// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum FonttasticStrings {
  public enum LaunchScreen {
    public enum AOu0W4Oe {
      /// Fonttastic
      public static let text = FonttasticStrings.tr("LaunchScreen", "aOu-0W-4Oe.text")
    }
  }
  public enum Localizable {
    public enum Onboarding {
      public enum Page {
        public enum First {
          /// Create and send postcards in messengers and social networks right from keyboard
          public static let title = FonttasticStrings.tr("Localizable", "onboarding.page.first.title")
        }
        public enum Second {
          /// Amazing collection of custom typefaces at your service
          public static let title = FonttasticStrings.tr("Localizable", "onboarding.page.second.title")
        }
      }
    }
    public enum Subscription {
      public enum ActionButton {
        /// Continue
        public static let title = FonttasticStrings.tr("Localizable", "subscription.actionButton.title")
      }
      public enum Error {
        public enum Message {
          /// Product already purchased. Please restore purchases to sync previously purchased subscription.
          public static let alreadyPurchased = FonttasticStrings.tr("Localizable", "subscription.error.message.alreadyPurchased")
          /// AppStore is probably down. Please, try again later.
          public static let appStoreIsDown = FonttasticStrings.tr("Localizable", "subscription.error.message.appStoreIsDown")
          /// This product is not available anymore. Please select another option.
          public static let ineligibleProduct = FonttasticStrings.tr("Localizable", "subscription.error.message.ineligibleProduct")
          /// There is a problem with your permissions. Please make sure you are signed in to AppleID and are able to make purchases.
          public static let insufficientPermissions = FonttasticStrings.tr("Localizable", "subscription.error.message.insufficientPermissions")
          /// There is an issue with your internet connection. Please connect to the internet and try again.
          public static let networkError = FonttasticStrings.tr("Localizable", "subscription.error.message.networkError")
          /// The system requires an additional confirmation of purchase. Please, follow Apple's instructions in order to complete the purchase.
          public static let paymentPending = FonttasticStrings.tr("Localizable", "subscription.error.message.paymentPending")
          /// Unfortunately, product is unavailable right now. Please either select another option or try again later.
          public static let productUnavailable = FonttasticStrings.tr("Localizable", "subscription.error.message.productUnavailable")
          /// Purchase was cancelled
          public static let purchaseCancelled = FonttasticStrings.tr("Localizable", "subscription.error.message.purchaseCancelled")
          /// There is probably an issue with your payment. Please make sure that your payment type is valid and try again.
          public static let purchaseInvalid = FonttasticStrings.tr("Localizable", "subscription.error.message.purchaseInvalid")
          /// Purhcases not allowed for this device or user. Please make sure you have logged in to AppleID and acknowledged Apple's privacy policy for Apple Music.
          public static let purchaseNotAllowed = FonttasticStrings.tr("Localizable", "subscription.error.message.purchaseNotAllowed")
          /// Something went wrong. Please, try again later.
          public static let unknownError = FonttasticStrings.tr("Localizable", "subscription.error.message.unknownError")
        }
        public enum OkAction {
          /// OK
          public static let title = FonttasticStrings.tr("Localizable", "subscription.error.okAction.title")
        }
        public enum Title {
          /// Purchase failed
          public static let `default` = FonttasticStrings.tr("Localizable", "subscription.error.title.default")
          /// Payment is Pending
          public static let pendingPayment = FonttasticStrings.tr("Localizable", "subscription.error.title.pendingPayment")
        }
      }
      public enum NavigationItem {
        /// Enter promocode
        public static let promocodeActionTitle = FonttasticStrings.tr("Localizable", "subscription.navigationItem.promocodeActionTitle")
        /// Restore purchases
        public static let restoreActionTitle = FonttasticStrings.tr("Localizable", "subscription.navigationItem.restoreActionTitle")
        /// Terms
        public static let termsActionTitle = FonttasticStrings.tr("Localizable", "subscription.navigationItem.termsActionTitle")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension FonttasticStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = FonttasticResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
