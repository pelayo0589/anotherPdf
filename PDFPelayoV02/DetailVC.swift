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
    
    var pdfUrl: URL?
    
    var px : CGFloat = 0.0
    var py : CGFloat = 0.0
    var pxStart : CGFloat = 0.0
    var pyStart : CGFloat = 0.0
    fileprivate var internalCropRect: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PDF"
        view.backgroundColor = .systemBackground
        pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pdfView)
        
      
        
        guard let pdf = pdfUrl else {
            return
        }
        
        if let document = PDFDocument(url: pdf) {
            pdfView.document = document
        
        }
        
        //Add Annotations
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .done, target: self, action: #selector(markupVC))
        
        // Drag Text
        
        handleDrag()
    }
    
    @objc func markupVC() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.setEditing(true, animated: true)
        present(previewController, animated: true)
    }
    
    func handleDrag() {
        let drag = UIPanGestureRecognizer(target: self, action: #selector(move))
        self.pdfView.addGestureRecognizer(drag)
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
    
    @objc func addTextToPage() {
        internalCropRect = CGRect(x: 100, y: 100, width: 100, height: 50)
        pdfView.currentPage?.addAnnotation(addText(rect: internalCropRect!))
    }
    
    func addText(rect: CGRect) -> PDFAnnotation {
        let text = PDFAnnotation(bounds: rect, forType: .widget, withProperties: nil)
        text.backgroundColor = .lightGray
        text.font = UIFont.systemFont(ofSize: 18)
        text.widgetStringValue = "Enter your text"
        text.widgetFieldType = .text
        return text
    }
    
    @objc func move(gesture : UIPanGestureRecognizer)
     {
         let newPoint = gesture.location(in: self.pdfView)
         print(newPoint)
         let state = gesture.state
         switch state
         {
         case .began:
           
             pxStart = gesture.location(in: self.pdfView).x
             pyStart = gesture.location(in: self.pdfView).y
            // internalCropRect = CGRect(x: pxStart, y: pyStart, width: newPoint.x, height: newPoint.y)
         case .ended: fallthrough
         case .changed:
             let translation = gesture.translation(in: self.pdfView)
             px = translation.x
             py = translation.y
            // internalCropRect = CGRect(x: pxStart, y: pyStart, width: translation.x, height: translation.y)
             self.pdfView.setNeedsDisplay()
         default: break
         }
         internalCropRect = CGRect(x: pxStart, y: pyStart, width: 100, height: 100)
         pdfView.currentPage?.addAnnotation(addText(rect: internalCropRect!))
     }
    
}

extension DetailVC: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 3
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = pdfUrl else {
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
    
    
}
