//
//  PasteboardWatcher.swift
//  Copy Meets Paste
//
//  Created by Samuel Seng on 2/21/23.
//

import Foundation
import SwiftUI

class PasteboardWatcher: NSObject {
    static var instance: PasteboardWatcher = PasteboardWatcher()
    
    private let pasteBoard = NSPasteboard.general
    private var timer: Timer?
    private var changeCount: Int
    
    var pasteSettings: PasteSettings?
    
    private override init() {
        self.changeCount = self.pasteBoard.changeCount
        
        super.init()
        
        self.startPolling()
    }
    
    func startPolling() {
        print("Starting")
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkForPasteboardChanges), userInfo: nil, repeats: true)
    }
    
    func stopPolling() {
        print("Stopping")
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func checkForPasteboardChanges() {
        if self.pasteBoard.changeCount != self.changeCount {
            let items = self.pasteBoard.pasteboardItems
            var replacement: String? = nil
            let removeStyling = self.pasteSettings?.removeStyling ?? false
            let removeTable = self.pasteSettings?.removeOuterTable ?? false
            if let items = items {
                items.forEach({ item in
                    if let data = item.string(forType: .html) {
                        if removeStyling {
                            replacement = Self.removeStyle(s: data)
                        }
                        else {
                            replacement = data
                        }
                    }
                })
            }
            if let replacement = replacement {
                if removeStyling || removeTable {
                    self.pasteBoard.clearContents()
                    self.pasteBoard.setString(replacement, forType: .html)
                }
            }
            self.changeCount = self.pasteBoard.changeCount
        }
    }
    
    static func removeStyle(s: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "style=\"[^\"]*\"")
            let regex2 = try NSRegularExpression(pattern: "style='[^']*'")
            let range = NSRange(location: 0, length: s.count)
            var out = regex.stringByReplacingMatches(in: s, range: range, withTemplate: "")
            let range2 = NSRange(location: 0, length: out.count)
            out = regex2.stringByReplacingMatches(in: out, range: range2, withTemplate: "")
            return out
        }
        catch {
            return s
        }
    }
    
}