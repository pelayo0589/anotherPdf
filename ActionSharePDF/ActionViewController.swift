//
//  ActionViewController.swift
//  ActionSharePDF
//
//  Created by Pelayo Mercado on 2/23/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import PDFKit

class ActionViewController: UIViewController {

    
    @IBOutlet weak var pdfView: PDFView!
    var pdfString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(kUTTypePDF as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypePDF as String, options: nil, completionHandler: { (pdfUrl, error) in
                        OperationQueue.main.addOperation {
                                if let pdfUrl = pdfUrl as? URL {
                                // pdfUrl now contains the path to the shared pdf data
                                    print("THIS IS YOUR PDF URL \(pdfUrl) ")
                                    let defaults = UserDefaults(suiteName: "group.miguelhoracio.PDFPelayoV02")
                                    defaults?.set(pdfUrl, forKey: "pdfUrl")
                        }
                    }
              }
         ) }

            }
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
//        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        
        let returnProvider = NSItemProvider(item: pdfString as NSSecureCoding?, typeIdentifier: UTType.pdf.identifier as String)
        let returnItem = NSExtensionItem()
        
        returnItem.attachments = [returnProvider]
        self.extensionContext!.completeRequest(returningItems: [returnItem], completionHandler: nil)
    }

}
        
