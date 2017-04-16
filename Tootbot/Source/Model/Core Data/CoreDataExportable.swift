//
//  CoreDataExportable.swift
//  Tootbot
//
//  Created by Michał Kałużny on 16/04/2017.
//
//

import Freddy

protocol CoreDataExportable: JSONDecodable {
    associatedtype Key: CoreDataKey

    var primaryKeyValue: Any { get }
}
