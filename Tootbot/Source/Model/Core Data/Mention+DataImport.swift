//
//  Mention+DataImport.swift
//  Tootbot
//
//  Created by Michał Kałużny on 16/04/2017.
//
//

import CoreData
import Foundation

extension Mention: APIImportable {
    typealias JSONModel = API.Mention

    static var primaryKeyPath: String {
        return #keyPath(userID)
    }

    func update(with model: API.Mention) {
        accountName = model.accountName
        profileURL = model.profileURL
        userID = Int64(model.accountID)
        username = model.username
    }
}
