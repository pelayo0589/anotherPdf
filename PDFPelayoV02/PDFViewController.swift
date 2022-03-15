//
//  ViewController.swift
//  PDFPelayoV02
//
//  Created by Pelayo Mercado on 2/20/22.
//

import UIKit
import PDFKit
import MobileCoreServices
import UniformTypeIdentifiers
import CoreData


class PDFViewController: UIViewController, UIDocumentPickerDelegate {
    
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 7, bottom: 2, trailing: 7)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)), subitem: item, count: 2)
        group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 30, trailing: 0)
        return NSCollectionLayoutSection(group: group)
    }))

    private var pdfView: PDFView!
    
    private var urlArray = [URL]()
    
    let defaultsForUrlArray = UserDefaults.standard
    
    var arrURLS = [String]()
    
    var pdfImage = [UIImage]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var  allPdfsUrls = [PDFUrls]()
    
    
    var testURLArray = [URL]()
    
    var pdfURLToPass: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        deleteAllData("PDFUrls")
//        allPdfsUrls.removeAll()
//        saveContext()
        
        title = "Home"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PDFImageCell.self, forCellWithReuseIdentifier: PDFImageCell.identifier)
        
        
        pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //view.addSubview(pdfView)

        let documentURL = Bundle.main.url(forResource: "blender", withExtension: "pdf")
        if let document = PDFDocument(url: documentURL!) {
            pdfView.document = document
            pdfView.currentPage?.addAnnotation(addText())
            
            if let attributes = document.documentAttributes {
                let keys = attributes.keys
                let firstKey = keys[keys.startIndex]
                
                
            }
 
            loadPdfs()
            
           
           
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(didTapActionPDF))
        
        
        arrURLS = defaultsForUrlArray.stringArray(forKey: "SavedURLStrings") ?? [String]()
        
        
    
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
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
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        collectionView.reloadData()
       
        
      
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        loadPdfs()
        collectionView.reloadData()
     
    }
    
    @objc func didTapActionPDF() {
        let defaults = UserDefaults(suiteName: "group.miguelhoracio.PDFPelayoV02")
        guard let pdfURL = defaults?.url(forKey: "pdfUrl") else {
            return
        }
        
        if let document = PDFDocument(url: pdfURL) {
            pdfView.document = document
            
        }
        
        
    }
    
    @objc func didTapAdd() {
        
            let types = UTType.types(tag: "pdf",
                                     tagClass: UTTagClass.filenameExtension,
                                     conformingTo: nil)
            let documentPickerController = UIDocumentPickerViewController(
                    forOpeningContentTypes: types)
            documentPickerController.delegate = self
            self.present(documentPickerController, animated: true, completion: nil)
        
    }
    
    func savePdf(urlString:String, fileName:String) {
           DispatchQueue.main.async {
               do {
                   let url = URL(string: urlString)
                   let pdfData = try? Data.init(contentsOf: url!)
                   let resourceDocPath = try (FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false))
                   let pdfNameFromUrl = "PDFPelayoV02-\(fileName)"
                   let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                   print(actualPath)
                   self.pdfURLToPass = actualPath
                   try pdfData?.write(to: actualPath, options: .atomic)
                   print("pdf successfully saved!")
               } catch {
                   print("Pdf could not be saved")
               }
         
           }
       }
    
    func savePdfForGroupContainer(urlString:String, fileName:String) {
           DispatchQueue.main.async {
               do {
                   let url = URL(string: urlString)
                   let pdfData = try? Data.init(contentsOf: url!)
                   let resourceDocPath = try FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.miguelhoracio.PDFPelayoV02")
                   let pdfNameFromUrl = "PDFPelayoV02-\(fileName)"
                   let actualPath = resourceDocPath?.appendingPathComponent(pdfNameFromUrl)
                   print(actualPath)
                   self.pdfURLToPass = actualPath
                   try pdfData?.write(to: actualPath!, options: .atomic)
                   print("pdf successfully saved!")
               } catch {
                   print("Pdf could not be saved")
               }
         
           }
       }
    
    
    
    func savePdfAlreadyExist(urlString:String, fileName:String) {
           DispatchQueue.main.async {
               let url = URL(string: urlString)
               let pdfData = try? Data.init(contentsOf: url!)
               let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
               let pdfNameFromUrl = "PDFPelayoV02-\(fileName)"
               let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            print(actualPath)
               self.pdfURLToPass = actualPath
               do {
               
                       //try pdfData?.write(to: actualPath, options: .atomic)
                   
                   
                   print("pdf already exist!")
               } catch {
                   print("Pdf could not be saved")
               }
           }
       }
    
    // check to avoid saving a file multiple times
    func pdfFileAlreadySaved(url:String, fileName:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("PDFPelayoV02-\(fileName)") {
                        status = true
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
        return status
    }
    
    

    private func addText() -> PDFAnnotation {
        let text = PDFAnnotation(bounds: CGRect(x: 100, y: 100, width: 100, height: 100), forType: .widget, withProperties: nil)
        text.backgroundColor = .lightGray
        text.font = UIFont.systemFont(ofSize: 18)
        text.widgetStringValue = "Enter your text"
        text.widgetFieldType = .text
        return text
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFile = urls.first else {
            return
        }
        guard selectedFile.startAccessingSecurityScopedResource() else {
            print("Error: could not access content of url \(selectedFile)")
            return
        }
     
        guard  let pdfDocument = PDFDocument(url: selectedFile) else {
            print("Error: could not create pdfdocument from \(selectedFile)")
            return
        }
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            pdfView.displayDirection = .vertical
            pdfView.backgroundColor = .blue
            pdfView.document = pdfDocument
       
       
        
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

}

extension PDFViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPdfsUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PDFImageCell.identifier, for: indexPath) as? PDFImageCell else {
            return UICollectionViewCell()
        }
        
        if allPdfsUrls[indexPath.row].pdfImage == nil {
            cell.pdfImageView.image = UIImage(systemName: "photo")
        }else {
            cell.pdfImageView.image = UIImage(data: allPdfsUrls[indexPath.row].pdfImage!)
        }
    
        cell.titleLabel.text = allPdfsUrls[indexPath.row].pdfUrls?.lastPathComponent
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let pdfUrl = allPdfsUrls[indexPath.row]
        let detailVC = DetailVC()
        detailVC.title = pdfUrl.pdfUrls?.lastPathComponent
        detailVC.pdfData = pdfUrl.pdfDocument
        detailVC.pdfURL = pdfURLToPass
        
        if pdfFileAlreadySaved(url: pdfUrl.pdfUrls!.absoluteString, fileName: pdfUrl.pdfUrls!.lastPathComponent) == true {
            savePdfAlreadyExist(urlString: pdfUrl.pdfUrls!.absoluteString, fileName: pdfUrl.pdfUrls!.lastPathComponent)
        } else {
            //savePdf(urlString: pdfUrl.pdfUrls!.absoluteString, fileName: pdfUrl.pdfUrls!.lastPathComponent)
            savePdfForGroupContainer(urlString: pdfUrl.pdfUrls!.absoluteString, fileName: pdfUrl.pdfUrls!.lastPathComponent)
        }
        
        
        
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailVC, animated: true)
        
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




