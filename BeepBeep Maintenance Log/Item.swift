//
//  Item.swift
//  BeepBeep Maintenance Log
//
//  Created by Joshua Runyan on 1/19/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
