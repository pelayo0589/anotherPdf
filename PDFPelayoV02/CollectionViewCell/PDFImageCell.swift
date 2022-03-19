//
//  PDFImageCell.swift
//  PDFPelayoV02
//
//  Created by Pelayo Mercado on 2/28/22.
//

import UIKit

class PDFImageCell: UICollectionViewCell {
    static let identifier = "PDFCollectionViewCell"
    
    public let pdfImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(pdfImageView)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
       
        
        pdfImageView.frame = CGRect(x: 40, y: 12, width: 90, height: 100)
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 5, y: pdfImageView.bottom+10, width: contentView.width, height: 50)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pdfImageView.image = nil
        titleLabel.text = nil
    }
    
    
}
