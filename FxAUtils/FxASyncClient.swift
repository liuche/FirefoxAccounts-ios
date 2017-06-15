/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Account
import Deferred
import Shared
import Sync

import Alamofire
import SwiftyJSON

open class FxASyncClient {
    var tokenServerToken: TokenServerToken

    // NB: static necessary to maintain reference to session manager
    fileprivate static let alamofire: SessionManager = {
        let ua = UserAgent.fxaUserAgent
        let configuration = URLSessionConfiguration.ephemeral
        return SessionManager.managerWithUserAgent(ua, configuration: configuration)
    }()

    public typealias Authorizer = (URLRequest) -> URLRequest
    fileprivate let authorizer: Authorizer

    init(token: TokenServerToken) {
        tokenServerToken = token
        self.authorizer = {
            (r: URLRequest) -> URLRequest in
            var req = r
            let helper = HawkHelper(id: token.id, key: token.key.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            req.setValue(helper.getAuthorizationValueFor(r), forHTTPHeaderField: "Authorization")
            return req
        }
    }

    fileprivate static func getStorageEndpoint(server: String, collection: String) -> URL? {
        return URL(string: server + "/" + collection)
    }

    public func getHistory() {
        if let url = FxASyncClient.getStorageEndpoint(server: self.tokenServerToken.api_endpoint, collection: "storage/history") {
            var req = URLRequest(url: url as URL)
            req.httpMethod = URLRequest.Method.get.rawValue
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            let authorized: URLRequest = self.authorizer(req)

            let request = FxASyncClient.alamofire.request(authorized)
                .validate(contentType: ["application/json"]) as DataRequest

            request.responsePartialParsedJSON({ (response: DataResponse<JSON>) in
                // TODO: extract and decrypt history from response
                print(response.response)
                print(response.result)
                print(response.result.value)
            })
        }
    }
}
