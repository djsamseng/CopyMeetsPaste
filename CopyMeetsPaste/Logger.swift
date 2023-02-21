//
//  Logger.swift
//  Copy Meets Paste
//
//  Created by Samuel Seng on 2/21/23.
//

import Foundation
import os.log

struct PasteLogger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let logger = Logger(subsystem: subsystem, category: "main")
}
