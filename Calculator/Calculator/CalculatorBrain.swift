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
    }
    
    private enum Op: CustomStringConvertible {
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Operand(Double)
        
        var invertOrder: Bool {
            get {
                switch self.description {
                case "÷": return true
                case "−": return true
                default: return false
                }
            }
        }
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
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
            }
        }
        return (nil, stack)
    }
    
    func push(operand operand: Double) -> Double? {
        stack.append(Op.Operand(operand))
        print(stack)
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
    
    func getStackString() -> String {
        return buildStackString("", stack: stack).currentString
    }
    
    private func buildStackString(currentString: String, stack: [Op]) -> (currentString: String, remainingStack: [Op]) {
        if !stack.isEmpty {
            var remainingStack = stack
            let op = remainingStack.removeLast()
            switch op {
            case .Operand(let value):
                return ("\(currentString)\(value)", remainingStack)
                
            case .UnaryOperation(_, _):
                let eval1 = buildStackString("", stack: remainingStack)
                return ("\(currentString)(\(op.description)\(eval1.currentString))", eval1.remainingStack)
                
            case .BinaryOperation(_, _):
                let eval1 = buildStackString("", stack: remainingStack)
                let eval2 = buildStackString("", stack: eval1.remainingStack)
                if op.invertOrder {
                    return ("\(currentString)(\(eval2.currentString)\(op.description)\(eval1.currentString))", eval2.remainingStack)
                } else {
                    return ("\(currentString)(\(eval1.currentString)\(op.description)\(eval2.currentString))", eval2.remainingStack)
                }
            }
        }
        return (currentString, stack)
    }
}