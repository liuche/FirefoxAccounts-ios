/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit

class ExampleViewController: UIViewController {
    var textButton: UIButton

    init() {
        textButton = UIButton()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.gray
        textButton.setTitle("Login", for: .normal)
        textButton.addTarget(self, action: #selector(loginPressed), for: UIControlEvents.touchUpInside)

        view.addSubview(textButton)

        let constraints = [
            textButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textButton.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            textButton.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
        ]

        NSLayoutConstraint.activate(constraints, translatesAutoresizingMaskIntoConstraints: false)
    }

    @IBAction func loginPressed() {
        let fxaViewController = FxAViewController()
        self.present(fxaViewController, animated: true, completion: {
            self.textButton.setTitle("Done", for: .normal)
            self.textButton.removeTarget(self, action: #selector(self.loginPressed), for: UIControlEvents.touchUpInside)
        })
    }
}
