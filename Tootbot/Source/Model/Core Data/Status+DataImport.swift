//
//  Status+DataImport.swift
//  Tootbot
//
//  Created by Michał Kałużny on 16/04/2017.
//
//

import CoreData
import Foundation

extension Status: APIImportable {
    typealias JSONModel = API.Status

    static var primaryKeyPath: String {
        return #keyPath(statusID)
    }

    func update(with model: API.Status) {
        statusID = Int64(model.id)
        applicationName = model.application?.name
        applicationURL = model.application?.websiteURL
        content = model.content
        createdAt = model.createdAt as NSDate
        isFavorited = model.isFavorited
        isReblogged = model.isReblogged
        isSensitive = model.isSensitive
        spoilerText = model.spoilerText
        updatedAt = NSDate()

        guard let context = managedObjectContext else {
            return
        }

        rebloggedStatus = (model.rebloggedStatus?.value).map { status in Status.upsert(model: status, in: context) }
        user = User.upsert(model: model.account, in: context)

        if let mentions = mentions {
            removeFromMentions(mentions)
        }

        for mentionModel in model.mentions {
            let mention = Mention.upsert(model: mentionModel, in: context)
            addToMentions(mention)
        }
    }
}
