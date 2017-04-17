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

extension Account {
    var avatarURL: URL? {
        get {
            return avatarURLString.flatMap { URL(string: $0) }
        }
        set {
            avatarURLString = newValue?.absoluteString
        }
    }

    var headerURL: URL? {
        get {
            return headerURLString.flatMap { URL(string: $0) }
        }
        set {
            headerURLString = newValue?.absoluteString
        }
    }
}

extension Attachment {
    var previewURL: URL? {
        get {
            return previewURLString.flatMap { URL(string: $0) }
        }
        set {
            previewURLString = newValue?.absoluteString
        }
    }

    var remoteURL: URL? {
        get {
            return remoteURLString.flatMap { URL(string: $0) }
        }
        set {
            remoteURLString = newValue?.absoluteString
        }
    }

    var textURL: URL? {
        get {
            return textURLString.flatMap { URL(string: $0) }
        }
        set {
            textURLString = newValue?.absoluteString
        }
    }

    var url: URL? {
        get {
            return urlString.flatMap { URL(string: $0) }
        }
        set {
            urlString = newValue?.absoluteString
        }
    }
}

extension Mention {
    var profileURL: URL? {
        get {
            return profileURLString.flatMap { URL(string: $0) }
        }
        set {
            profileURLString = newValue?.absoluteString
        }
    }
}

extension Status {
    var applicationURL: URL? {
        get {
            return applicationURLString.flatMap { URL(string: $0) }
        }
        set {
            applicationURLString = newValue?.absoluteString
        }
    }
}

extension User {
    var avatarURL: URL? {
        get {
            return avatarURLString.flatMap { URL(string: $0) }
        }
        set {
            avatarURLString = newValue?.absoluteString
        }
    }

    var headerURL: URL? {
        get {
            return headerURLString.flatMap { URL(string: $0) }
        }
        set {
            headerURLString = newValue?.absoluteString
        }
    }

    var websiteURL: URL? {
        get {
            return websiteURLString.flatMap { URL(string: $0) }
        }
        set {
            websiteURLString = newValue?.absoluteString
        }
    }
}
