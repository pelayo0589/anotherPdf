//
//  DetailVC.swift
//  PDFPelayoV02
//
//  Created by Pelayo Mercado on 3/7/22.
//

import UIKit
import PDFKit
import CoreData
import QuickLook


class DetailVC: UIViewController {
    
    var pdfView: PDFView!
    var allPdfsUrls = [PDFUrls]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var pdfData: Data?
    var pdfURL: URL?
    
    var actualPath: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PDF"
        view.backgroundColor = .systemBackground
        pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pdfView)
        
            pdfView.maxScaleFactor = 4.0;
            pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit;
            pdfView.autoScales = true;
          
           
          
        pdfView.translatesAutoresizingMaskIntoConstraints = false;
           
        pdfView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true;
        pdfView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true;
        pdfView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true;
        pdfView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true;
        
        guard let pdf = pdfURL else {
            return
        }
        
        print(pdf)
        
        if let document = PDFDocument(url: pdf) {
            pdfView.document = document
            
 
        }
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .done, target: self, action: #selector(markupVC))

     
    }
    
    func savePdfData(pdfData: Data, fileName: String) {
        DispatchQueue.main.async {
            let pdfData = pdfData
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last!
            let pdfNameFromUrl = "PDFPelayoV02-\(fileName).pdf"
            self.actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
           print(resourceDocPath)
            do {
                try pdfData.write(to: self.actualPath!, options: .atomic)
                
                print("pdf successfully saved!")
            } catch {
                print("Pdf could not be saved")
            }
        }
    }
    
    func savePdf(urlString:String, fileName:String) {
           DispatchQueue.main.async {
               let url = URL(string: urlString)
               let pdfData = try? Data.init(contentsOf: url!)
               let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
               let pdfNameFromUrl = "PDFPelayoV02-\(fileName).pdf"
               let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
               do {
                   try pdfData?.write(to: actualPath, options: .atomic)
                   print(actualPath)
                   print("pdf successfully saved!")
               } catch {
                   print("Pdf could not be saved")
               }
           }
       }
    
    @objc func markupVC() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.setEditing(true, animated: true)
        present(previewController, animated: true)
    }
    

    
    func loadPdfs() {
        let request: NSFetchRequest<PDFUrls> = PDFUrls.fetchRequest()
        print(request)
        do {
            allPdfsUrls = try context.fetch(request)
           
        } catch {
            print("Error fetching data \(error)")
        }
    }
    

    
}

extension DetailVC: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 5
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = pdfURL else {
        
              fatalError("Could not load \(index).pdf")
          }
    
        return url as QLPreviewItem
    }
    
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .updateContents
    }
    
    func saveContext () {
       
        if context.hasChanges {
            do {
                try context.save()
            } catch {
           
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    
}
