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
        learnOp(Op.BinaryOperation("✕", *, false))
        learnOp(Op.BinaryOperation("+", +, false))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }, true))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }, true))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.NamedValue("π", M_PI))
    }
    
    private enum Op: CustomStringConvertible {
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double, Bool)
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
                case .BinaryOperation(let symbol, _, _):
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
            case .BinaryOperation(_, let operation, _):
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
    }
    
    var description: String {
        get {
            return describeStack("", stack: stack).currentString
        }
    }
    
    private func describeStack(currentString: String, stack: [Op]) -> (currentString: String, remainingStack: [Op]) {
        if !stack.isEmpty {
            var remainingStack = stack
            let op = remainingStack.removeLast()
            switch op {
            case .Operand(let value):
                return ("\(currentString)\(value)", remainingStack)
                
            case .UnaryOperation(_, _):
                let eval1 = describeStack("", stack: remainingStack)
                return ("\(currentString)(\(op.description)(\(eval1.currentString)))", eval1.remainingStack)
                
            case .BinaryOperation(_, _, let invertOrder):
                let eval1 = describeStack("", stack: remainingStack)
                let eval2 = describeStack("", stack: eval1.remainingStack)
                if invertOrder {
                    return ("\(currentString)(\(eval2.currentString)\(op.description)\(eval1.currentString))", eval2.remainingStack)
                } else {
                    return ("\(currentString)(\(eval1.currentString)\(op.description)\(eval2.currentString))", eval2.remainingStack)
                }
            
            case .NamedValue(let symbol, _):
                return ("\(currentString)\(symbol)", remainingStack)
                
            case .Variable(let symbol):
                return ("\(currentString)\(symbol)", remainingStack)
            }
        }
        return (currentString, stack)
    }
}