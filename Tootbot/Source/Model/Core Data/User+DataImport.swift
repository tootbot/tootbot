//
//  User+DataImport.swift
//  Tootbot
//
//  Created by Michał Kałużny on 16/04/2017.
//
//

import Foundation
import CoreData

extension User: APIImportable {
    typealias JSONModel = API.Account

    static var primaryKeyPath: String {
        return #keyPath(userID)
    }

    func update(with model: API.Account) {
        userID = Int64(model.id)
        username = model.username
        accountName = model.accountName
        displayName = model.displayName
        note = model.note
        websiteURL = model.websiteURL
        avatarURL = model.avatarURL
        headerURL = model.headerURL
        isLocked = model.isLocked
        createdAt = model.createdAt as NSDate
        followersCount = Int64(model.followersCount)
        followingCount = Int64(model.followersCount)
        statusesCount = Int64(model.statusesCount)

        updatedAt = NSDate()
    }
}
