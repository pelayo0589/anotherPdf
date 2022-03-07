//
//  ShareViewController.swift
//  ShareExtensionPDF
//
//  Created by Pelayo Mercado on 2/24/22.
//

import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers
import PDFKit
import CoreData



class ShareViewController: UIViewController {
    
    var pdfString: String?
    
    // MARK: - Core Data stack
      lazy var persistentContainer: NSPersistentContainer = {
          /*
           The persistent container for the application. This implementation
           creates and returns a container, having loaded the store for the
           application to it. This property is optional since there are legitimate
           error conditions that could cause the creation of the store to fail.
           */
          let container = NSCustomPersistentContainer(name: "PDFCoreDataModel")
          
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
              if let error = error as NSError? {
                  // Replace this implementation with code to handle the error appropriately.
                  // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                  
                  /*
                   Typical reasons for an error here include:
                   * The parent directory does not exist, cannot be created, or disallows writing.
                   * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                   * The device is out of space.
                   * The store could not be migrated to the current model version.
                   Check the error message to determine what the actual problem was.
                   */
                  fatalError("Unresolved error \(error), \(error.userInfo)")
              }
          })
          return container
      }()
      
      // MARK: - Core Data Saving support
      
      func saveContext () {
          let context = persistentContainer.viewContext
          if context.hasChanges {
              do {
                  try context.save()
              } catch {
                  // Replace this implementation with code to handle the error appropriately.
                  // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                  let nserror = error as NSError
                  fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
              }
          }
      }

      func someOtherFunction() {
        // get the managed context
        let managedContext = self.persistentContainer.viewContext
        // have fun
      }
    
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else {
            print("it is not a pdf document")
            return nil }
        guard let page = document.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }

        return img
    }
    

    
    var pdfUrls = [PDFUrls]()
   
    var pdfImagesArray = [UIImage]()
    
    override func viewDidLoad() {
        
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
                                  
                                    self.openContainerApp()
                                    let context = self.persistentContainer.viewContext
                                    
                                    var newPdfUrls = PDFUrls(context: context)
                                    newPdfUrls.pdfUrls = pdfUrl
                                    self.pdfImagesArray.append(self.drawPDFfromURL(url: pdfUrl)!)
                                
                                  newPdfUrls.pdfImage = self.drawPDFfromURL(url: pdfUrl)?.pngData()
                                    
                                
                                    
                                    self.saveContext()
                      
                                    self.extensionContext!.cancelRequest(withError:NSError())
                                    
                                
                               
                                
                                    
                 
                                    
                        }
                    }
              }
         ) }

            }
        }
        

        
        
    }
    
   


    
    // For skip compile error.
   @objc func openURL(_ url: URL) {
        return
    }

    func openContainerApp() {
        var responder: UIResponder? = self as UIResponder
        let selector = #selector(openURL(_:))
        while responder != nil {
            if responder!.responds(to: selector) && responder != self {
                responder!.perform(selector, with: URL(string: "PDFUrl://")!)
                return
            }
            responder = responder?.next
        }
    }
    

}

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

