//
//  ContentView.swift
//  CopyMeetsPaste
//
//  Created by Samuel Seng on 2/21/23.
//

import SwiftUI

struct Header: View{
    var body: some View {
        VStack {
            HStack {
                Text("Copy Meets Paste")
                    .font(.title)
            }
        }
    }
}

class PasteSettings: ObservableObject {
    @Published var appEnabled: Bool = true
    
    @Published var removeStyling: Bool = true
    @Published var removeOuterTable: Bool = true
}

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

struct SettingForm: View {
    @ObservedObject var pasteSettings: PasteSettings
    var pasteBoardWatcher: PasteboardWatcher = PasteboardWatcher.instance
    var body: some View {
        VStack {
            HStack {
                Form {
                    Section(content: {
                        Toggle(isOn: $pasteSettings.appEnabled, label: {
                            Label("Enabled", systemImage: "flag.fill")
                        })
                        .onChange(of: pasteSettings.appEnabled, perform: { newVal in
                            if newVal {
                                self.pasteBoardWatcher.startPolling()
                            }
                            else{
                                self.pasteBoardWatcher.stopPolling()
                            }
                        })
                    })
                    Spacer()
                        .frame(height: 25)
                    Section(content: {
                        Toggle(isOn: $pasteSettings.removeStyling, label: {
                            Label("Remove styling", systemImage: "textformat")
                        })
                        Toggle(isOn: $pasteSettings.removeOuterTable, label: {
                            Label("Remove outer table", systemImage: "tablecells")
                        })
                    })
                }
                .toggleStyle(.switch)
            }
            .padding(.horizontal)
            .onAppear(perform: {
                self.pasteBoardWatcher.pasteSettings = self.pasteSettings
            })
        }
    }
}

struct InstructionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("1. Leave this app running in the background")
            Text("2. Copy and paste as usual")
            Text("3. Voila! Pasted content is fixed")
        }
        .padding(.vertical)
    }
}

struct ContentView: View {
    @StateObject private var pasteSettings = PasteSettings()
    var body: some View {
        VStack {
            Header()
            SettingForm(pasteSettings: pasteSettings)
            InstructionsView()
        }
        .frame(idealWidth: 400, idealHeight: 600)
        .padding()
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
