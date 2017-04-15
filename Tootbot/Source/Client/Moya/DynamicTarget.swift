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

import Moya

public struct DynamicTarget<SubTarget>: TargetType where SubTarget: SubTargetType {
    public var baseURL: URL
    public var subTarget: SubTarget

    public init(baseURL: URL, subTarget: SubTarget) {
        self.baseURL = baseURL
        self.subTarget = subTarget
    }

    public var path: String {
        return subTarget.path
    }

    public var method: Moya.Method {
        return subTarget.method
    }

    public var parameters: [String: Any]? {
        return subTarget.parameters
    }

    public var parameterEncoding: ParameterEncoding {
        return subTarget.parameterEncoding
    }

    public var sampleData: Data {
        return subTarget.sampleData
    }

    public var task: Task {
        return subTarget.task
    }

    public var validate: Bool {
        return subTarget.validate
    }
}
