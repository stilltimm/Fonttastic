//
//  KeyboardViewController.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FontasticTools

class KeyboardViewController: UIInputViewController {

    private let latinAlphabetKeyboardView = KeyboardView(
        viewModel: LatinAlphabetQwertyKeyboardViewModel(
            design: .init(
                letterSpacing: 4,
                rowSpacing: 6,
                edgeInsets: .init(vertical: 4, horizontal: 4),
                symbolDesign: .init(
                    backgroundColor: UIColor(white: 0.9, alpha: 1.0),
                    foregroundColor: .white,
                    highlightedColor: UIColor(white: 0.96, alpha: 1.0),
                    shadowSize: 2.0,
                    cornerRadius: 4.0,
                    labelFont: UIFont.systemFont(ofSize: 24, weight: .light)
                )
            )
        )
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(latinAlphabetKeyboardView)
        constrain(view, latinAlphabetKeyboardView) { view, keyboard in
            keyboard.edges == view.edges
            view.height == 200
        }

        latinAlphabetKeyboardView.didSubmitSymbolEvent.subscribe(self) { [weak self] symbol in
            self?.textDocumentProxy.insertText(symbol)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }
}
