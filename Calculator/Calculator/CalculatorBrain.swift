//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Raphael Gontijo Lopes on 23/3/16.
//  Copyright © 2016 Raphael Gontijo Lopes. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    init() {
        knownOps["✕"] = Op.BinaryOperation("✕", *)
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["÷"] = Op.BinaryOperation("÷", { $1 / $0 })
        knownOps["−"] = Op.BinaryOperation("−", { $1 - $0 })
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
    }
    
    private enum Op {
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Operand(Double)
    }
    
    private var stack = [Op]()
    private var knownOps = [String:Op]()
    
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
    
    func push(operand operand: Double) {
        stack.append(Op.Operand(operand))
    }
    
    func perform(symbol symbol: String) {
        if let operation = knownOps[symbol] {
            stack.append(operation)
        }
    }
}