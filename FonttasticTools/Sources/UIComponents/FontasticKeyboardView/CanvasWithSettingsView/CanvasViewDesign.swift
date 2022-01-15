//
//  CanvasViewDesign.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 16.11.2021.
//

import UIKit

public class CanvasViewDesign: Codable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {
        case fontModel
        case fontSize
        case backgroundColorHex
        case textColorHex
        case textAlignmentRawValue
        case backgroundImagePngData
    }

    // MARK: - Pulic Instance Properties

    public var fontModel: FontModel
    public var fontSize: CGFloat
    public var backgroundColor: UIColor
    public var backgroundImage: UIImage?
    public var textColor: UIColor
    public var textAlignment: NSTextAlignment

    // MARK: - Initializers

    public init(
        fontModel: FontModel,
        fontSize: CGFloat,
        backgroundColor: UIColor,
        backgroundImage: UIImage?,
        textColor: UIColor,
        textAlignment: NSTextAlignment
    ) {
        self.fontModel = fontModel
        self.fontSize = fontSize
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.textColor = textColor
        self.textAlignment = textAlignment
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fontModel = try container.decode(FontModel.self, forKey: .fontModel)
        self.fontSize = try container.decode(CGFloat.self, forKey: .fontSize)

        let backgroundColorHex = try container.decode(UInt32.self, forKey: .backgroundColorHex)
        let textColorHex = try container.decode(UInt32.self, forKey: .textColorHex)
        self.backgroundColor = UIColor(hex: backgroundColorHex)
        self.textColor = UIColor(hex: textColorHex)

        let textAlignmentRawValue = try container.decode(NSTextAlignment.RawValue.self, forKey: .textAlignmentRawValue)
        self.textAlignment = NSTextAlignment(rawValue: textAlignmentRawValue) ?? Constants.defaultTextAlignment
        self.backgroundImage = nil
    }

    // MARK: - Public Instance Methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fontModel, forKey: .fontModel)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(backgroundColor.hexValue, forKey: .backgroundColorHex)
        try container.encode(textColor.hexValue, forKey: .textColorHex)
        try container.encode(textAlignment.rawValue, forKey: .textAlignmentRawValue)
    }
}

private enum Constants {

    static let defaultTextAlignment: NSTextAlignment = .center
}
