//
//  Attachment+DataImport.swift
//  Tootbot
//
//  Created by Michał Kałużny on 16/04/2017.
//
//

import CoreData
import Foundation

extension Attachment: APIImportable {
    typealias JSONModel = API.Attachment

    static var primaryKeyPath: String {
        return #keyPath(attachmentID)
    }

    func update(with model: API.Attachment) {
        attachmentID = Int64(model.id)
        mediaTypeValue = model.type
        previewURL = model.previewURL
        remoteURL = model.remoteURL
        textURL = model.textURL
        url = model.url

        updatedAt = NSDate()
    }
}
