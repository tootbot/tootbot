//
//  DataImport.swift
//  Tootbot
//
//  Created by Michał Kałużny on 16/04/2017.
//
//

import CoreData

protocol APIImportable {
    associatedtype JSONModel: CoreDataExportable

    associatedtype T: NSManagedObject = Self

    static var primaryKeyPath: String { get }

    static func find(matching model: JSONModel, in context: NSManagedObjectContext) -> T?

    static func upsert(model: JSONModel, in context: NSManagedObjectContext) -> T

    func update(with model: JSONModel)
}

extension APIImportable where Self == T {
    static func find(matching model: JSONModel, in context: NSManagedObjectContext) -> T? {
        let fetchRequest = Self.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: Self.primaryKeyPath), rightExpression: NSExpression(forConstantValue: model.primaryKeyValue), modifier: .direct, type: .equalTo)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first as? Self
        } catch {
            print("Core Data fetch error -> \(error)")
            return nil
        }
    }

    static func upsert(model: JSONModel, in context: NSManagedObjectContext) -> T {
        let managedObject: T
        if let existing = self.find(matching: model, in: context) {
            managedObject = existing
        } else {
            managedObject = T(context: context)
        }

        managedObject.update(with: model)
        return managedObject
    }
}
