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

import Alamofire
import Moya
import TootModel

public enum ApplicationScope: String {
    case read
    case write
    case follow
}

public enum MastodonRoute {
    case account(id: Int)
    case currentUser
    case updateCurrentUser(displayName: String?, note: String?, avatarImage: FormData?, headerImage: FormData?)
    case accountFollowers(id: Int)
    case accountFollowing(id: Int)
    case accountStatuses(id: Int, onlyMedia: Bool?, excludeReplies: Bool?)
    case followAccount(id: Int)
    case unfollowAccount(id: Int)
    case blockAccount(id: Int)
    case unblockAccount(id: Int)
    case muteAccount(id: Int)
    case unmuteAccount(id: Int)
    case accountRelationships(ids: [Int])
    case searchAccounts(query: String, limit: Int?)
    case registerApp(clientName: String, redirectURI: String, scopes: Set<ApplicationScope>, websiteURL: URL?)
    case blockedAccounts
    case favoritedStatuses
    case followRequests
    case authorizeFollowRequest(id: Int)
    case rejectFollowRequest(id: Int)
    case followRemoteAccount(uri: String)
    case instance
    case uploadMedia(file: Moya.MultipartFormData)
    case mutedAccounts
    case notifications
    case notification(id: Int)
    case clearNotifications
    case reports
    case reportUser(id: Int, statusIDs: [Int], comment: String)
    case search(query: String, resolve: Bool)
    case status(id: Int)
    case statusContext(id: Int)
    case statusCard(id: Int)
    case statusRebloggedBy(id: Int)
    case statusFavoritedBy(id: Int)
    case postStatus(status: String, inReplyToID: Int?, mediaIDs: [Int]?, isSensitive: Bool?, spoilerText: Bool?, visibility: StatusVisibility?)
    case deleteStatus(id: Int)
    case reblogStatus(id: Int)
    case unreblogStatus(id: Int)
    case favoriteStatus(id: Int)
    case unfavoriteStatus(id: Int)
    case homeTimeline
    case publicTimeline(localOnly: Bool)
    case tagTimeline(hashtag: String, localOnly: Bool)

    public var path: String {
        switch self {
        case .account(let id):
            return "/api/v1/accounts/\(id)"
        case .currentUser:
            return "/api/v1/accounts/verify_credentials"
        case .updateCurrentUser:
            return "/api/v1/accounts/update_credentials"
        case .accountFollowers(let id):
            return "/api/v1/accounts/\(id)/followers"
        case .accountFollowing(let id):
            return "/api/v1/accounts/\(id)/following"
        case .accountStatuses(let id, _, _):
            return "/api/v1/accounts/\(id)/statuses"
        case .followAccount(let id):
            return "/api/v1/accounts/\(id)/follow"
        case .unfollowAccount(let id):
            return "/api/v1/accounts/\(id)/unfollow"
        case .blockAccount(let id):
            return "/api/v1/accounts/\(id)/block"
        case .unblockAccount(let id):
            return "/api/v1/accounts/\(id)/unblock"
        case .muteAccount(let id):
            return "/api/v1/accounts/\(id)/mute"
        case .unmuteAccount(let id):
            return "/api/v1/accounts/\(id)/unmute"
        case .accountRelationships:
            return "/api/v1/accounts/relationships"
        case .searchAccounts:
            return "/api/v1/accounts/search"
        case .registerApp:
            return "/api/v1/apps"
        case .blockedAccounts:
            return "/api/v1/blocks"
        case .favoritedStatuses:
            return "/api/v1/favorites"
        case .followRequests:
            return "/api/v1/follow_requests"
        case .authorizeFollowRequest:
            return "/api/v1/follow_requests/authorize"
        case .rejectFollowRequest:
            return "/api/v1/follow_requests/reject"
        case .followRemoteAccount:
            return "/api/v1/follows"
        case .instance:
            return "/api/v1/instance"
        case .uploadMedia:
            return "/api/v1/media"
        case .mutedAccounts:
            return "/api/v1/mutes"
        case .notifications:
            return "/api/v1/notifications"
        case .notification(let id):
            return "/api/v1/notification/\(id)"
        case .clearNotifications:
            return "/api/v1/notifications/clear"
        case .reports:
            return "/api/v1/reports"
        case .reportUser:
            return "/api/v1/reports"
        case .search:
            return "/api/v1/search"
        case .status(let id):
            return "/api/v1/statuses/\(id)"
        case .statusContext(let id):
            return "/api/v1/statuses/\(id)/context"
        case .statusCard(let id):
            return "/api/v1/statuses/\(id)/card"
        case .statusRebloggedBy(let id):
            return "/api/v1/statuses/\(id)/reblogged_by"
        case .statusFavoritedBy(let id):
            return "/api/v1/statuses/\(id)/favourited_by"
        case .postStatus:
            return "/api/v1/statuses"
        case .deleteStatus(let id):
            return "/api/v1/statuses/\(id)"
        case .reblogStatus(let id):
            return "/api/v1/statuses/\(id)/reblog"
        case .unreblogStatus(let id):
            return "/api/v1/statuses/\(id)/unreblog"
        case .favoriteStatus(let id):
            return "/api/v1/statuses/\(id)/favourite"
        case .unfavoriteStatus(let id):
            return "/api/v1/statuses/\(id)/unfavourite"
        case .homeTimeline:
            return "/api/v1/timelines/home"
        case .publicTimeline:
            return "/api/v1/timelines/public"
        case .tagTimeline(let hashtag, _):
            return "/api/v1/timelines/tag/\(hashtag)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .account:
            return .get
        case .currentUser:
            return .get
        case .updateCurrentUser:
            return .patch
        case .accountFollowers:
            return .get
        case .accountFollowing:
            return .get
        case .accountStatuses:
            return .get
        case .followAccount:
            return .get
        case .unfollowAccount:
            return .get
        case .blockAccount:
            return .get
        case .unblockAccount:
            return .get
        case .muteAccount:
            return .get
        case .unmuteAccount:
            return .get
        case .accountRelationships:
            return .get
        case .searchAccounts:
            return .get
        case .registerApp:
            return .post
        case .blockedAccounts:
            return .get
        case .favoritedStatuses:
            return .get
        case .followRequests:
            return .get
        case .authorizeFollowRequest:
            return .post
        case .rejectFollowRequest:
            return .post
        case .followRemoteAccount:
            return .post
        case .instance:
            return .get
        case .uploadMedia:
            return .post
        case .mutedAccounts:
            return .get
        case .notifications:
            return .get
        case .notification:
            return .get
        case .clearNotifications:
            return .post
        case .reports:
            return .get
        case .reportUser:
            return .post
        case .search:
            return .get
        case .status:
            return .get
        case .statusContext:
            return .get
        case .statusCard:
            return .get
        case .statusRebloggedBy:
            return .get
        case .statusFavoritedBy:
            return .get
        case .postStatus:
            return .post
        case .deleteStatus:
            return .delete
        case .reblogStatus:
            return .post
        case .unreblogStatus:
            return .post
        case .favoriteStatus:
            return .post
        case .unfavoriteStatus:
            return .post
        case .homeTimeline:
            return .get
        case .publicTimeline:
            return .get
        case .tagTimeline:
            return .get
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .account:
            return nil
        case .currentUser:
            return nil
        case .updateCurrentUser(let displayName, let note, let avatarImage, let headerImage):
            var parameters = [String: Any]()
            parameters["display_name"] = displayName
            parameters["note"] = note
            parameters["avatar"] = avatarImage?.base64EncodedString
            parameters["header"] = headerImage?.base64EncodedString
            return parameters
        case .accountFollowers:
            return nil
        case .accountFollowing:
            return nil
        case .accountStatuses(_, let onlyMedia, let excludeReplies):
            var parameters = [String: Any]()
            parameters["only_media"] = onlyMedia
            parameters["exclude_replies"] = excludeReplies
            return parameters
        case .followAccount:
            return nil
        case .unfollowAccount:
            return nil
        case .blockAccount:
            return nil
        case .unblockAccount:
            return nil
        case .muteAccount:
            return nil
        case .unmuteAccount:
            return nil
        case .accountRelationships(let ids):
            return ["id": ids]
        case .searchAccounts(let query, let limit):
            var parameters: [String: Any] = ["q": query]
            parameters["limit"] = limit
            return parameters
        case .registerApp(let clientName, let redirectURI, let scopes, let websiteURL):
            var parameters: [String: Any] = [
                "client_name": clientName,
                "redirect_uris": redirectURI,
                "scopes": scopes.map({ $0.rawValue }).joined(separator: " "),
            ]
            parameters["website"] = websiteURL?.absoluteString
            return parameters
        case .blockedAccounts:
            return nil
        case .favoritedStatuses:
            return nil
        case .followRequests:
            return nil
        case .authorizeFollowRequest(let id):
            return ["id": id]
        case .rejectFollowRequest(let id):
            return ["id": id]
        case .followRemoteAccount(let uri):
            return ["uri": uri]
        case .instance:
            return nil
        case .uploadMedia:
            return nil
        case .mutedAccounts:
            return nil
        case .notifications:
            return nil
        case .notification:
            return nil
        case .clearNotifications:
            return nil
        case .reports:
            return nil
        case .reportUser(let id, let statusIDs, let comment):
            return ["account_id": id, "status_ids": statusIDs, "comment": comment]
        case .search(let query, let resolve):
            var parameters: [String: Any] = ["q": query]
            parameters["resolve"] = resolve
            return parameters
        case .status:
            return nil
        case .statusContext:
            return nil
        case .statusCard:
            return nil
        case .statusRebloggedBy:
            return nil
        case .statusFavoritedBy:
            return nil
        case .postStatus(let status, let inReplyToID, let mediaIDs, let isSensitive, let spoilerText, let visibility):
            var parameters: [String: Any] = ["status": status]
            parameters["in_reply_to_id"] = inReplyToID
            parameters["media_ids"] = mediaIDs
            parameters["sensitive"] = isSensitive
            parameters["spoiler_text"] = spoilerText
            parameters["visibility"] = visibility?.rawValue
            return parameters
        case .deleteStatus:
            return nil
        case .reblogStatus:
            return nil
        case .unreblogStatus:
            return nil
        case .favoriteStatus:
            return nil
        case .unfavoriteStatus:
            return nil
        case .homeTimeline:
            return nil
        case .publicTimeline(let localOnly):
            var parameters = [String: Any]()
            parameters["local"] = localOnly
            return parameters
        case .tagTimeline(_, let localOnly):
            var parameters = [String: Any]()
            parameters["local"] = localOnly
            return parameters
        }
    }

    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        switch self {
        case .uploadMedia(let file):
            return .upload(.multipart([file]))
        default:
            return .request
        }
    }

    public var validate: Bool {
        return false
    }
}

public enum MastodonService: TargetType {
    case instance(baseURL: URL, route: MastodonRoute)

    public var baseURL: URL {
        switch self {
        case .instance(let baseURL, _):
            return baseURL
        }
    }

    public var path: String {
        switch self {
        case .instance(_, let route):
            return route.path
        }
    }

    public var method: Moya.Method {
        switch self {
        case .instance(_, let route):
            return route.method
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .instance(_, let route):
            return route.parameters
        }
    }

    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .instance(_, let route):
            return route.parameterEncoding
        }
    }

    public var sampleData: Data {
        switch self {
        case .instance(_, let route):
            return route.sampleData
        }
    }

    public var task: Task {
        switch self {
        case .instance(_, let route):
            return route.task
        }
    }

    public var validate: Bool {
        switch self {
        case .instance(_, let route):
            return route.validate
        }
    }
}
