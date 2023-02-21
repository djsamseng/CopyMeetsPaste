//
//  ContentView.swift
//  CopyMeetsPaste
//
//  Created by Samuel Seng on 2/21/23.
//

import Foundation
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



struct SettingForm: View {
    var userSettings: UserSettings
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
                            userSettings.save()
                        })
                    })
                    Spacer()
                        .frame(height: 25)
                    Section(content: {
                        Toggle(isOn: $pasteSettings.removeStyling, label: {
                            Label("Remove styling", systemImage: "textformat")
                        })
                        .onChange(of: pasteSettings.removeStyling, perform: { newVal in
                            userSettings.save()
                        })
                        Toggle(isOn: $pasteSettings.removeOuterTable, label: {
                            Label("Remove outer table", systemImage: "tablecells")
                        })
                        .onChange(of: pasteSettings.removeOuterTable, perform: { newVal in
                            userSettings.save()
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
    @StateObject private var userSettings = UserSettings()
    var body: some View {
        VStack {
            Header()
            if let pasteSettings = userSettings.pasteSettings {
                SettingForm(userSettings: userSettings, pasteSettings: pasteSettings)
            }
            InstructionsView()
            Spacer()
        }
        .frame(idealWidth: 400, idealHeight: 600)
        .padding()
        .onAppear(perform: {
            self.userSettings.load()
        })
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
