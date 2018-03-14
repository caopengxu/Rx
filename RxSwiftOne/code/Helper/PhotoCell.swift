//
//  PhotoCell.swift
//  RxSwiftOne
//
//  Created by caopengxu on 2018/3/13.
//  Copyright © 2018年 caopengxu. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkMark: UIImageView!
    
    var representedAssetIdentifier: String!
    var isCheckMarked: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }

    func selected()
    {
        self.flipCheckMark()
        setNeedsDisplay()
        
        UIView.animate(withDuration: 0.1, animations: {[weak self] in
            if let isChickMarked = self?.isCheckMarked
            {
                self?.checkMark.alpha = isChickMarked ? 1 : 0
            }}
        )
    }
    
    func flipCheckMark()
    {
        self.isCheckMarked = !self.isCheckMarked
    }
}
