//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Raphael Gontijo Lopes on 23/3/16.
//  Copyright © 2016 Raphael Gontijo Lopes. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var stack = [Op]()
    private var knownOps = [String:Op]()
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("✕", *))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.NamedValue("π", M_PI))
    }
    
    private enum Op: CustomStringConvertible {
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case NamedValue(String, Double)
        case Operand(Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .NamedValue(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    func eval() -> Double? {
        let (result, _) = eval(stack)
        return result
    }
    
    private func eval(stack: [Op]) -> (result: Double?, remainingStack: [Op]) {
        if !stack.isEmpty {
            var remainingStack = stack
            let op = remainingStack.removeLast()
            switch op {
            case .Operand(let value):
                return (value, remainingStack)
            case .UnaryOperation(_, let operation):
                let eval1 = eval(remainingStack)
                if let operand = eval1.result {
                    return (operation(operand), eval1.remainingStack)
                }
            case .BinaryOperation(_, let operation):
                let eval1 = eval(remainingStack)
                if let operand1 = eval1.result {
                    let eval2 = eval(eval1.remainingStack)
                    if let operand2 = eval2.result {
                        return (operation(operand1, operand2), eval2.remainingStack)
                    }
                }
            case .NamedValue(_, let value):
                return (value, remainingStack)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingStack)
            }
        }
        return (nil, stack)
    }
    
    func push(operand operand: Double) -> Double? {
        stack.append(Op.Operand(operand))
        return eval()
    }
    
    func push(variable symbol: String) -> Double? {
        stack.append(Op.Variable(symbol))
        return eval()
    }
    
    func perform(operation symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            stack.append(operation)
        }
        return eval()
    }
    
    func clear() {
        stack = [Op]()
        variableValues = [String:Double]()
    }
    
    var description: String {
        get {
            var (desc, remainingStack) = describe(stack: stack)
            while !remainingStack.isEmpty {
                let (newDesc, newRemainingStack) = describe(stack: remainingStack)
                remainingStack = newRemainingStack
                desc = "\(newDesc), \(desc)"
            }
            if desc == "?" { return "" }
            return "\(desc)="
        }
    }
    
    private func describe(stack stack: [Op]) -> (currentString: String, remainingStack: [Op]) {
        if !stack.isEmpty {
            var remainingStack = stack
            let op = remainingStack.removeLast()
            switch op {
            case .Operand(let value):
                return ("\(value)", remainingStack)
                
            case .UnaryOperation(_, _):
                let eval1 = describe(stack: remainingStack)
                return ("\(op.description)(\(eval1.currentString))", eval1.remainingStack)
                
            case .BinaryOperation(_, _):
                let eval1 = describe(stack: remainingStack)
                let eval2 = describe(stack: eval1.remainingStack)
                
                let currentString1 = (Double(eval1.currentString) != nil || variableValues[eval1.currentString] != nil || knownOps[eval1.currentString] != nil ? eval1.currentString : "(\(eval1.currentString))")
                let currentString2 = (Double(eval2.currentString) != nil || variableValues[eval2.currentString] != nil || knownOps[eval2.currentString] != nil ? eval2.currentString : "(\(eval2.currentString))")
                
                return ("\(currentString2)\(op.description)\(currentString1)", eval2.remainingStack)
            
            case .NamedValue(let symbol, _):
                return (symbol, remainingStack)
                
            case .Variable(let symbol):
                return (symbol, remainingStack)
            }
        }
        return ("?", stack)
    }
}