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

    private let fontasticKeyboardView = FontasticKeyboardView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(fontasticKeyboardView)
        constrain(view, fontasticKeyboardView) { view, keyboard in
            keyboard.edges == view.edges
        }


//        latinAlphabetKeyboardViewModel.didSubmitSymbolEvent.subscribe(self) { [weak self] symbol in
//            self?.textDocumentProxy.insertText(symbol)
//        }
//        latinAlphabetKeyboardViewModel.shouldDeleteSymbolEvent.subscribe(self) { [weak self] in
//            self?.textDocumentProxy.deleteBackward()
//        }
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
