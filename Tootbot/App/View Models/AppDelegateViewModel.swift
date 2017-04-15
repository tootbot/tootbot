//
// Copyright (C) 2017 Alexsander Akers and Tootbot Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import CoreData
import ReactiveSwift

enum AppDelegateError: Error {
    case dataInitializationFailure(underlying: Error)
}

class AppDelegateViewModel {
    let dataController: DataController
    let networkingController: NetworkingController

    init(dataController: DataController, networkingController: NetworkingController) {
        self.dataController = dataController
        self.networkingController = networkingController
    }

    func hasAccounts() throws -> Bool {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        return try dataController.viewContext.count(for: fetchRequest) > 0
    }

    func initializeDataController() -> SignalProducer<Void, AppDelegateError> {
        return dataController.load()
            .ignoreValues()
            .mapError(AppDelegateError.dataInitializationFailure)
    }

    func addAccountViewModel() -> AddAccountViewModel {
        return AddAccountViewModel(dataController: dataController, networkingController: networkingController)
    }
}
