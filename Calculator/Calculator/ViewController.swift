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
    
//    @IBAction func appendSpecial(sender: UIButton) {
//        if currentlyTypingNumber { enter() }
//        switch sender.currentTitle! {
//            case "π": displayValue = M_PI
//            default: break
//        }
//        enter()
//    }
    
    @IBAction func clear() {
        brain.clear()
        display.text = "0"
        history.text = brain.getStackString()
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
            if newValue == nil {
                display.text = "ERROR"
            } else {
                display.text = "\(newValue!)"
                currentlyTypingNumber = false
            }
        }
    }
    
    @IBAction func enter() {
        currentlyTypingNumber = false
        if let value = displayValue {
            displayValue = brain.push(operand: value)
        } else {
            displayValue = 0
        }
        history.text = brain.getStackString()
    }
    
    @IBAction func operate(sender: UIButton) {
        if currentlyTypingNumber { enter() }
        displayValue = brain.perform(operation: sender.currentTitle!)
        history.text = brain.getStackString()
    }
}

