//
//  FontSelectionViewController.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.11.2021.
//

import Foundation
import UIKit

public protocol FontSelectionControllerDelegate: AnyObject {

    func didSelectFontModel(_ fontModel: FontModel)
    func didCancelFontSelection()
}

public class FontSelectionController: UIViewController {

    public weak var delegate: FontSelectionControllerDelegate?
}
