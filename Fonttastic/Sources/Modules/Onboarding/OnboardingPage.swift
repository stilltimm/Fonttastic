//
//  OnboardingPage.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 05.12.2021.
//

import Foundation

enum OnboardingPage: UInt8, CaseIterable {

    case firstAppShowcase
    case secondAppShowcase
    case paywall

    // MARK: - Type Properties

    static let allCases: [OnboardingPage] = [
        .firstAppShowcase,
        .secondAppShowcase,
        .paywall
    ]

    // MARK: - Instance Properties

    var next: OnboardingPage? {
        guard let indexOfSelf = Self.allCases.firstIndex(of: self) else { return nil }
        return Self.allCases[safe: indexOfSelf + 1]
    }

    var prev: OnboardingPage? {
        guard let indexOfSelf = Self.allCases.firstIndex(of: self) else { return nil }
        return Self.allCases[safe: indexOfSelf - 1]
    }
}
