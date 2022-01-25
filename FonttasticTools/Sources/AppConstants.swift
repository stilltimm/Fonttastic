//
//  AppConstants.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.12.2021.
//

import Foundation

public class AppConstants {

    // MARK: - Public Type Properties

    public static let appGroupName: String = "group.88Q8M3ZBSJ.com.romandegtyarev.fonttastic"

    // MARK: - Private Type Properties

    private static let environment: [String: Any]? = {
        guard
            let environmentPropertyListURL = Bundle(for: AppConstants.self).url(
                forResource: "Environment",
                withExtension: "plist"
            ),
            let environmentDictionary = NSDictionary(contentsOf: environmentPropertyListURL)
        else { return nil }

        return environmentDictionary as? [String: Any]
    }()

    // MARK: - Internal Type Properties

    static let purchasesAPIKey: String? = environment?["PURCHASES_API_KEY"] as? String
    static let amplitudeAPIKey: String? = environment?["AMPLITUDE_API_KEY"] as? String
    static let bugsnagAPIKey: String? = environment?["BUGSNAG_API_KEY"] as? String
}
