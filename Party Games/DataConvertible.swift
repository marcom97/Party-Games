//
//  DataConvertible.swift
//  Party Games
//
//  Created by Marco Matamoros on 2016-12-21.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import UIKit

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

// Extension
extension DataConvertible {
    
    init?(data: Data) {
        self = data.subdata(in: 0..<MemoryLayout<Self>.size).withUnsafeBytes {
            $0.pointee
        }
    }
    
    var data: Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}
