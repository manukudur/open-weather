//
//  WebKitViewController.swift
//  open-weather
//
//  Created by Manoj Kumar on 14/05/23.
//

import UIKit
import WebKit

class WebKitViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load the PDF file
        if let pdfPath = Bundle.main.path(forResource: "Documentation", ofType: "pdf"),
            let pdfData = NSData(contentsOfFile: pdfPath) {
            webView.load(pdfData as Data, mimeType: "application/pdf", characterEncodingName: "", baseURL: Bundle.main.bundleURL)
        } else {
            let htmlString = "<h1>Oops! Something went wrong.</h1>"
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }

}
