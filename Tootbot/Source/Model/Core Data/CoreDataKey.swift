//
//  CoreDataKey.swift
//  Tootbot
//
//  Created by Michał Kałużny on 16/04/2017.
//
//

import Freddy

protocol CoreDataKey: JSONPathType {
    static var primaryKey: Self { get }
}

extension CoreDataKey where Self: RawRepresentable, Self.RawValue: JSONPathType {
    func value(in dictionary: [String : JSON]) throws -> JSON {
        return try rawValue.value(in: dictionary)
    }

    func value(in array: [JSON]) throws -> JSON {
        return try rawValue.value(in: array)
    }
}
