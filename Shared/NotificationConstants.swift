/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

extension Notification.Name {
    public static let DataLoginDidChange = Notification.Name("DataLoginDidChange")

    // add a property to allow the observation of firefox accounts
    public static let FirefoxAccountChanged = Notification.Name("FirefoxAccountChanged")

    public static let FirefoxAccountProfileChanged = Notification.Name("FirefoxAccountProfileChanged")

    public static let FirefoxAccountDeviceRegistrationUpdated = Notification.Name("FirefoxAccountDeviceRegistrationUpdated")

    // MARK: Notification UserInfo Keys
    public static let UserInfoKeyHasSyncableAccount = Notification.Name("UserInfoKeyHasSyncableAccount")

    // Fired when the FxA account has been verified. This should only be fired by the FxALoginStateMachine.
    public static let FirefoxAccountVerified = Notification.Name("FirefoxAccountVerified")

    // Fired when the login synchronizer has finished applying remote changes
    public static let DataRemoteLoginChangesWereApplied = Notification.Name("DataRemoteLoginChangesWereApplied")

    public static let ProfileDidStartSyncing = Notification.Name("ProfileDidStartSyncing")
    public static let ProfileDidFinishSyncing = Notification.Name("ProfileDidFinishSyncing")

    public static let DatabaseWasRecreated = Notification.Name("DatabaseWasRecreated")
}
