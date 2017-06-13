/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Account
import Deferred
import Shared
import Sync

open class FxASyncClient {
    var tokenServerToken: TokenServerToken

    init(token: TokenServerToken) {
        tokenServerToken = token
    }
}
