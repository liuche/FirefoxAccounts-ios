/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Account
import WebKit
import SwiftyJSON

protocol FxAContentViewControllerDelegate: class {
    func contentViewControllerDidSignIn(_ viewController: FxAViewController, withFlags: FxALoginFlags)
    func contentViewControllerDidCancel(_ viewController: FxAViewController)
}

class FxAViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var fxaOptions = FxALaunchParams()
    var url: URL!
    // The web view that displays content.
    var webView: WKWebView!
    weak var delegate: FxAContentViewControllerDelegate?

    fileprivate enum RemoteCommand: String {
        case canLinkAccount = "can_link_account"
        case loaded = "loaded"
        case login = "login"
        case sessionStatus = "session_status"
        case signOut = "sign_out"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hard-coded dev account
        self.url = LatestDevFirefoxAccountConfiguration().signInURL

        view.backgroundColor = UIColor.white
        self.webView = makeWebView()
        webView.navigationDelegate = self

        view.addSubview(webView)

        let constraints = [
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints, translatesAutoresizingMaskIntoConstraints: false)

        webView.load(URLRequest(url: url))
    }

    func makeWebView() -> WKWebView {
        let source = getJS()
        let userScript = WKUserScript(
            source: source,
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )

        // Handle messages from the content server (via our user script).
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        contentController.add(LeakAvoider(delegate:self), name: "accountsCommandHandler")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 1, height: 1),
            configuration: config
        )
        return webView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Handle a message coming from the content server.
    func handleRemoteCommand(_ rawValue: String, data: JSON) {
        print(rawValue)
        if let command = RemoteCommand(rawValue: rawValue) {
            // Add in states later.
        }
    }
    
    // Dispatch webkit messages originating from our child webview.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Make sure we're communicating with a trusted page. That is, ensure the origin of the
        // message is the same as the origin of the URL we initially loaded in this web view.
        // Note that this exploit wouldn't be possible if we were using WebChannels; see
        // https://developer.mozilla.org/en-US/docs/Mozilla/JavaScript_code_modules/WebChannel.jsm
        let origin = message.frameInfo.securityOrigin
        guard origin.`protocol` == url.scheme && origin.host == url.host && origin.port == (url.port ?? 0) else {
            print("Ignoring message - \(origin) does not match expected origin \(url.origin)")
            return
        }

        if message.name == "accountsCommandHandler" {
            let body = JSON(message.body)
            let detail = body["detail"]
            handleRemoteCommand(detail["command"].stringValue, data: detail["data"])
        }
    }
}

fileprivate func getJS() -> String {
    let fileRoot = Bundle.main.path(forResource: "FxASignIn", ofType: "js")
    return (try! NSString(contentsOfFile: fileRoot!, encoding: String.Encoding.utf8.rawValue)) as String
}

extension FxAViewController: FxAPushLoginDelegate {
    func accountLoginDidSucceed(withFlags flags: FxALoginFlags) {
        DispatchQueue.main.async {
            self.delegate?.contentViewControllerDidSignIn(self, withFlags: flags)
        }
    }
    
    func accountLoginDidFail() {
        DispatchQueue.main.async {
            self.delegate?.contentViewControllerDidCancel(self)
        }
    }
}

/*
 LeakAvoider prevents leaks with WKUserContentController
 http://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
 */

class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
