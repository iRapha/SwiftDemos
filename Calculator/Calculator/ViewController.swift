//
//  ViewController.swift
//  Calculator
//
//  Created by Raphael Gontijo Lopes on 22/3/16.
//  Copyright © 2016 Raphael Gontijo Lopes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var currentlyTypingNumber = false
    var numberHasPoint: Bool {
        get {
            return display.text!.containsString(".")
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        if currentlyTypingNumber {
            display.text = display.text! + sender.currentTitle!
        } else {
            display.text = sender.currentTitle!
            currentlyTypingNumber = true
        }
    }
    
    @IBAction func appendPoint(sender: UIButton) {
        if !currentlyTypingNumber || !numberHasPoint {
            appendDigit(sender)
        }
    }
    
    @IBAction func appendSpecial(sender: UIButton) {
        if currentlyTypingNumber { enter() }
        switch sender.currentTitle! {
            case "π": displayValue = M_PI
            default: break
        }
        enter()
    }
    
    func appendToHistory(item: String) {
        if let hist = history.text {
            history.text = hist + item + " "
        } else {
            history.text = item + " "
        }
    }
    
    @IBAction func clear() {
        stack = Array<Double>()
        display.text = "0"
        history.text = ""
    }
    
    var stack = Array<Double>()
    var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = "\(newValue)"
            currentlyTypingNumber = false
        }
    }
    
    @IBAction func enter() {
        currentlyTypingNumber = false
        stack.append(displayValue)
        appendToHistory(display.text!)
    }
    
    @IBAction func operate(sender: UIButton) {
        if currentlyTypingNumber { enter() }
        appendToHistory(sender.currentTitle!)
        switch sender.currentTitle! {
        case "✕": perform(operation: { $0 * $1 })
        case "÷": perform(operation: { $1 / $0 })
        case "+": perform(operation: { $0 + $1 })
        case "−": perform(operation: { $1 - $0 })
        case "√": perform(operation: { sqrt($0) })
        case "sin": perform(operation: { sin($0) })
        case "cos": perform(operation: { cos($0) })
        default: break
        }
    }

    private func perform(operation op : (Double, Double) -> Double) {
        if stack.count >= 2 {
            displayValue = op(stack.removeLast(), stack.removeLast())
            enter()
        }
    }
    
    private func perform(operation op : Double -> Double) {
        if stack.count >= 1 {
            displayValue = op(stack.removeLast())
            enter()
        }
    }
}

