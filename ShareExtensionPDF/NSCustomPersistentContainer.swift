//
//  NSCustomPersistentContainer.swift
//  ShareExtensionPDF
//
//  Created by Pelayo Mercado on 3/3/22.
//

import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.miguelhoracio.PDFPelayoV02")
        storeURL = storeURL?.appendingPathComponent("PDFPelayoV02.sqlite")
        return storeURL!
    }

}
