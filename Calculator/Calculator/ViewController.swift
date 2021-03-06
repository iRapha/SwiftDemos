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
    
    let brain = CalculatorBrain()
    
    var currentlyTypingNumber = false
    var numberHasPoint: Bool {
        get {
            return display.text!.containsString(".")
        }
    }
    
    var displayValue : Double? {
        get {
            if let value = Double(display.text!) {
                return value
            } else {
                return nil
            }
        }
        set {
            if let value = newValue {
                display.text = "\(value)"
                currentlyTypingNumber = false
            } else {
                display.text = ""
            }
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
    
    @IBAction func clear() {
        brain.clear()
        display.text = "0"
        history.text = brain.description
    }
    
    @IBAction func enter() {
        currentlyTypingNumber = false
        if let value = displayValue {
            displayValue = brain.push(operand: value)
        } else {
            displayValue = 0
        }
        history.text = brain.description
    }
    
    @IBAction func operate(sender: UIButton) {
        if currentlyTypingNumber { enter() }
        displayValue = brain.perform(operation: sender.currentTitle!)
        history.text = brain.description
    }
    
    @IBAction func getM() {
        if currentlyTypingNumber { enter() }
        displayValue = brain.push(variable: "M")
        history.text = brain.description
    }
    
    @IBAction func setM() {
        currentlyTypingNumber = false
        if let value = displayValue {
            brain.variableValues["M"] = value
        }
        displayValue = brain.eval()
        history.text = brain.description
    }
}

