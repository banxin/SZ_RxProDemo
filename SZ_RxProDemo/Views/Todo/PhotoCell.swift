//
//  PhotoCell.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/10/16.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit

/// 相册选择cell
class PhotoCell: UICollectionViewCell {
    
    var imageView: UIImageView = UIImageView()
    var checkmark: UIImageView = UIImageView()
    
    var representedAssetIdentifier: String!
    var isCheckmarked: Bool = false
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension PhotoCell {
    
    /// 设置UI
    private func setupUI() {
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
        
        checkmark.image = UIImage(named: "check_selected")
        checkmark.alpha = 0
        addSubview(checkmark)
        
        checkmark.snp.makeConstraints { (make) in
        
            make.right.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
    }
}

// MARK: - public method
extension PhotoCell {
    
    func flipCheckmark() {
        
        self.isCheckmarked = !self.isCheckmarked
    }
    
    func selected() {
        
        self.flipCheckmark()
        
        setNeedsDisplay()
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            
            if let isCheckmarked = self?.isCheckmarked {
                self?.checkmark.alpha = isCheckmarked ? 1 : 0
            }
        })
    }
}
