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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
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
//        let defaults = UserDefaults(suiteName: "group.miguelhoracio.PDFPelayoV02")
//        guard let pdfURL = defaults?.url(forKey: "pdfUrl") else {
//            return
//        }
        
//        for i in 0..<allPdfsUrls.count {
//            guard let pdfURL = allPdfsUrls[i].pdfUrls else {
//                return
//            }
//            if let document = PDFDocument(url: pdfURL) {
//                pdfView.document = document
//                urlArray.append(pdfURL)
//                pdfImage.append(drawPDFfromURL(url: pdfURL)!)
//
//            }
//        }
     
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
     
       
        cell.pdfImageView.image = drawPDFfromURL(url: allPdfsUrls[indexPath.row].pdfUrls!)
        
        print(allPdfsUrls[indexPath.row].pdfUrls!)
        //print(drawPDFfromURL(url: allPdfsUrls[indexPath.row].pdfUrls!))
        cell.titleLabel.text = allPdfsUrls[indexPath.row].pdfUrls?.lastPathComponent
        return cell
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




