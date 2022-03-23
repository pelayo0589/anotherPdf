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


class PDFViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 15, bottom: 5, trailing: 15)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(170)), subitem: item, count: 2)
        group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10)
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
    
    var imagePicker = UIImagePickerController()
    
    var pdfURLforFiles: URL?
    var pdfURLforUIImage: URL?
    
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
            
            
            if let attributes = document.documentAttributes {
                let keys = attributes.keys
                let firstKey = keys[keys.startIndex]
                
                
            }
 
            loadPdfs()
            
            imagePicker.delegate = self
            
            addLongTapGesture()
           
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didTapCamera))
        
        
        arrURLS = defaultsForUrlArray.stringArray(forKey: "SavedURLStrings") ?? [String]()
        
   
    }
    
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        let touchPoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint), indexPath.section == 0 else {
            return
        }
        
        
        
        let actionSheet = UIAlertController(title: allPdfsUrls[indexPath.row].pdfActualPath?.lastPathComponent, message: "Would you like to delete this PDF?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            self?.context.delete((self?.allPdfsUrls[indexPath.row])!)
            self?.saveContext()
            self?.allPdfsUrls.removeAll()
            self?.loadPdfs()
            self?.collectionView.reloadData()
            
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func didTapCamera() {

  
           let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
           alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
               self.openCamera()
           }))
           
           alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
               self.openGallary()
           }))
           
           alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
           
       
           
           self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
        {
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

        func openGallary()
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        createPDFDataFromImage(image: image)
        

        
        let newPdfUrls = PDFUrls(context: context)
        newPdfUrls.pdfUrls = pdfURLforUIImage
        newPdfUrls.pdfImage = self.drawPDFfromURL(url: pdfURLforUIImage!)?.pngData()
        newPdfUrls.pdfActualPath = pdfURLforUIImage
        self.saveContext()
        loadPdfs()
        collectionView.reloadData()
    }
    
    func createPDFDataFromImage(image: UIImage) -> NSMutableData {
        let pdfData = NSMutableData()
        let imgView = UIImageView.init(image: image)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginPDFContextToData(pdfData, imageRect, nil)
        UIGraphicsBeginPDFPage()
        let context = UIGraphicsGetCurrentContext()
        imgView.layer.render(in: context!)
        UIGraphicsEndPDFContext()

        //try saving in doc dir to confirm:
        let dir = try FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.miguelhoracio.PDFPelayoV02")
        let path = dir?.appendingPathComponent("\(image.description).pdf")
        self.pdfURLforUIImage = path

        do {
                try pdfData.write(to: path!, options: NSData.WritingOptions.atomic)
        } catch {
            print("error catched")
        }

        return pdfData
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
    

    
    @objc func didTapAdd() {
        
            let types = UTType.types(tag: "pdf",
                                     tagClass: UTTagClass.filenameExtension,
                                     conformingTo: nil)
            let documentPickerController = UIDocumentPickerViewController(
                    forOpeningContentTypes: types)
            documentPickerController.delegate = self
            self.present(documentPickerController, animated: true, completion: nil)
        
    }



    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFile = urls.first else {
            return
        }
        print(selectedFile)
        guard selectedFile.startAccessingSecurityScopedResource() else {
            print("Error: could not access content of url \(selectedFile)")
            return
        }
        
        savePdfForGroupContainer(urlString: selectedFile.absoluteString, fileName: selectedFile.lastPathComponent)
     
        let newPdfUrls = PDFUrls(context: context)
        newPdfUrls.pdfUrls = selectedFile
        //newPdfUrls.pdfDocument = pdfDocument?.dataRepresentation()
        newPdfUrls.pdfImage = self.drawPDFfromURL(url: selectedFile)?.pngData()
        newPdfUrls.pdfActualPath = pdfURLforFiles
        self.saveContext()
        loadPdfs()
        collectionView.reloadData()
       
        
    }
    
    func savePdfForGroupContainer(urlString:String, fileName:String) {
           
               do {
                   let url = URL(string: urlString)
                   let pdfData = try? Data.init(contentsOf: url!)
                   let resourceDocPath = try FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.miguelhoracio.PDFPelayoV02")
                   let pdfNameFromUrl = "PDFPelayoV02-\(fileName)"
                   let actualPath = resourceDocPath?.appendingPathComponent(pdfNameFromUrl)
                   self.pdfURLforFiles = actualPath
                   try pdfData?.write(to: actualPath!, options: .atomic)
                   print("pdf successfully saved!")
               } catch {
                   print("Pdf could not be saved")
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
        detailVC.pdfURL = pdfUrl.pdfActualPath
        
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






