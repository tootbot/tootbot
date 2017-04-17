//
// Copyright (C) 2017 Tootbot Contributors
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
import Moya
import ReactiveSwift

enum AddAccountError: Swift.Error {
    case invalidApplicationProperties
    case applicationRegistrationFailure(MoyaError)
    case authenticationFailure(MoyaError)
    case dataController(DataControllerError)
    case coreDataSaveError
}

class AddAccountViewModel {
    let networkingController: NetworkingController

    init(networkingController: NetworkingController) {
        self.networkingController = networkingController
    }

    func loginURL(on instanceURI: String) -> SignalProducer<URL, AddAccountError> {
        guard let properties = Bundle.main.applicationProperties else {
            return SignalProducer(error: .invalidApplicationProperties)
        }

        return networkingController.applicationCredentials(for: properties, on: instanceURI)
            .mapError(AddAccountError.applicationRegistrationFailure)
            .map { credentials in self.networkingController.loginURL(applicationProperties: properties, applicationCredentials: credentials)! }
    }

    func loginResult(on instanceURI: String) -> Signal<DataController, AddAccountError> {
        return networkingController.loginResult(for: instanceURI)
            .mapError(AddAccountError.authenticationFailure)
            .flatMap(.latest) { accountModel in
                DataController.create(forAccount: accountModel, instanceURI: instanceURI).mapError(AddAccountError.dataController)
            }
    }
}
