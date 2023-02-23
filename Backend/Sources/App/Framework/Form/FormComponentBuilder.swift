//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 01. 01..
//

@resultBuilder
public struct ArrayBuilder<Element> {
    public static func buildPartialBlock(first: Element) -> [Element] { [first] }
    public static func buildPartialBlock(first: [Element]) -> [Element] { first }
    public static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] { accumulated + [next] }
    public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] { accumulated + next }
    
    // Empty Case
    public static func buildBlock() -> [Element] { [] }
    // If/Else
    public static func buildEither(first: [Element]) -> [Element] { first }
    public static func buildEither(second: [Element]) -> [Element] { second }
    // Just ifs
    public static func buildIf(_ element: [Element]?) -> [Element] { element ?? [] }
    // fatalError()
    public static func buildPartialBlock(first: Never) -> [Element] {}
}

// MARK: - Array.init(builder:)
public extension Array {
    init(@ArrayBuilder<Element> builder: () -> [Element]) {
        self.init(builder())
    }
}

