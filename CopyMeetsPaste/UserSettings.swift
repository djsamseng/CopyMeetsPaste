//
//  UserSettings.swift
//  Copy Meets Paste
//
//  Created by Samuel Seng on 2/21/23.
//

import Foundation

class UserSettings: ObservableObject {
    private static let suiteName = "CopyMeetsPasteSettingsSuite"
    private static let storeKey = "PasteSettings"
    
    @Published var pasteSettings: PasteSettings? = nil
    
    func load() {
        DispatchQueue.global(qos: .background).async {
            do {
                guard let data = UserDefaults(suiteName: Self.suiteName)?.data(forKey: Self.storeKey) else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {
                            print("Failed to create new settings no self")
                            return
                        }
                        print("Created new settings")
                        self.pasteSettings = PasteSettings()
                    }
                    return
                }
                let decoded = try JSONDecoder().decode(PasteSettings.self, from: data)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        print("Failed to set decoded settings no self")
                        return
                    }
                    print("Loaded decoded settings")
                    self.pasteSettings = decoded
                }
            }
            catch {
                print("Error loading", error)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        print("Failed to set new settings after error no self")
                        return
                    }
                    self.pasteSettings = PasteSettings()
                }
            }
        }
    }
    
    func save() {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(self.pasteSettings)
                UserDefaults(suiteName: Self.suiteName)?.set(data, forKey: Self.storeKey)
                print("Saved settings")
            }
            catch {
                print("Failed to save:", error)
            }
        }
    }
}

class PasteSettings: ObservableObject, Codable {
    @Published var appEnabled: Bool = true
    
    @Published var removeStyling: Bool = true
    @Published var removeOuterTable: Bool = true
    
    enum CodingKeys: CodingKey {
        case appEnabled
        case removeStyling
        case removeOuterTable
    }
    
    init() {
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appEnabled = try container.decode(Bool.self, forKey: .appEnabled)
        self.removeStyling = try container.decode(Bool.self, forKey: .removeStyling)
        self.removeOuterTable = try container.decode(Bool.self, forKey: .removeOuterTable)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.appEnabled, forKey: .appEnabled)
        try container.encode(self.removeStyling, forKey: .removeStyling)
        try container.encode(self.removeOuterTable, forKey: .removeOuterTable)
    }
}
