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
                            PasteLogger.logger.error("Failed to create new settings no self")
                            return
                        }
                        PasteLogger.logger.info("Created new settings")
                        self.pasteSettings = PasteSettings()
                    }
                    return
                }
                let decoded = try JSONDecoder().decode(PasteSettings.self, from: data)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        PasteLogger.logger.error("Failed to set decoded settings no self")
                        return
                    }
                    PasteLogger.logger.info("Loaded decoded settings")
                    self.pasteSettings = decoded
                }
            }
            catch {
                PasteLogger.logger.error("Error loading \(error.localizedDescription, privacy: .public)")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        PasteLogger.logger.error("Failed to set new settings after error no self")
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
                PasteLogger.logger.info("Saved settings")
            }
            catch {
                PasteLogger.logger.error("Failed to save: \(error.localizedDescription, privacy: .public)")
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
