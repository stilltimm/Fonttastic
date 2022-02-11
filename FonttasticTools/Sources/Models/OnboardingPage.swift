//
//  OnboardingPage.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 05.12.2021.
//

import Foundation

public enum OnboardingPage: String, CaseIterable {

    case firstAppShowcase
    case secondAppShowcase
    case paywall

    // MARK: - Type Properties

    public static let allCases: [OnboardingPage] = [
        .firstAppShowcase,
        .secondAppShowcase,
        .paywall
    ]

    // MARK: - Instance Properties

    public var next: OnboardingPage? {
        guard let indexOfSelf = Self.allCases.firstIndex(of: self) else { return nil }
        return Self.allCases[safe: indexOfSelf + 1]
    }

    public var prev: OnboardingPage? {
        guard let indexOfSelf = Self.allCases.firstIndex(of: self) else { return nil }
        return Self.allCases[safe: indexOfSelf - 1]
    }
}
