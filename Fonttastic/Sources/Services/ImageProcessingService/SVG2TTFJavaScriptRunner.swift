//
//  SVG2TTFJavaScriptRunner.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 18.10.2021.
//

// swiftlint:disable comment_spacing
//import Foundation
//import JavaScriptCore
//import FonttasticTools
//
//class SVG2TTFJavaScriptRunner {
//
//    func run(inputs: [String]) {
//        guard let context = JSContext() else { return }
//
//        let testFunctionName = "testFunction"
//        let jsSource = """
//        var \(testFunctionName) = function(inputs) {
//          return "Inputs count: " + inputs.length + ", inputs list: " + inputs.join(', ');
//        }
//        """
//        context.evaluateScript(jsSource)
//
//        guard
//            let testFunction = context.objectForKeyedSubscript(testFunctionName),
//            let result = testFunction.call(withArguments: [inputs])
//        else {
//            logger.debug("Failed to get testFunction or create result")
//            return
//        }
//
//        if result.isString, let stringValue = result.toString() {
//            logger.debug("String result: \"\(stringValue)\"")
//        } else {
//            logger.debug("Not string result: \(result)")
//        }
//    }
//}
