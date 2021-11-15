//
//  SVG2TTFJavaScriptRunner.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 18.10.2021.
//

import Foundation
import JavaScriptCore

class SVG2TTFJavaScriptRunner {

    func run(inputs: [String]) {
        guard let context = JSContext() else { return }

        let testFunctionName = "testFunction"
        let jsSource = """
        var \(testFunctionName) = function(inputs) {
          return "Inputs count: " + inputs.length + ", inputs list: " + inputs.join(', ');
        }
        """
        context.evaluateScript(jsSource)

        guard
            let testFunction = context.objectForKeyedSubscript(testFunctionName),
            let result = testFunction.call(withArguments: [inputs])
        else {
            print("Failed to get testFunction or create result")
            return
        }

        if result.isString, let stringValue = result.toString() {
            print("String result: \"\(stringValue)\"")
        } else {
            print("Not string result: ", result)
        }
    }
}
