//
//  PhotoCollectionViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/10/16.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import Photos
import RxSwift

private let reuseIdentifier = "PhotoMemo"

class PhotoCollectionViewController: UICollectionViewController {
    
    fileprivate let selectedPhotosSubject = PublishSubject<UIImage>()
    
    var selectedPhotos: Observable<UIImage> {
        
        /*
         共享订阅:
         
         多次订阅，共享同一个observe
         */
        return selectedPhotosSubject.asObservable().share()
    }
    
    let bag = DisposeBag()
    
    fileprivate lazy var photos = PhotoCollectionViewController.loadPhotos()
    fileprivate lazy var imageManager = PHCachingImageManager()
    
    fileprivate lazy var thumbnailsize: CGSize = {
        
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        // 检测相册权限
        checkPhotoAuthorized()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super .viewWillDisappear(animated)
        
        selectedPhotosSubject.onCompleted()
    }
    
    deinit {
        
        print("photo collection release")
    }
}

// MARK: - UI
extension PhotoCollectionViewController {
    
    /// 设置UI
    private func setupUI() {
        
        title = "Choose Photo"
        self.collectionView?.backgroundColor = UIColor.colorWithHex(hexString: "f1f2f3")
        
        setCellSpace()
        self.collectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func setCellSpace() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: (width - 40) / 4, height: (width - 40) / 4)
        collectionView!.collectionViewLayout = layout
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension PhotoCollectionViewController {
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailsize, contentMode: .aspectFill, options: nil, resultHandler: { (image, _) in
                
            guard let image = image else { return }
            
            if cell.representedAssetIdentifier == asset.localIdentifier {
                
                cell.imageView.image = image
            }
        })
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.selected()
        }
        
        imageManager.requestImage(for: asset,
                                  targetSize: view.frame.size,
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler: { [weak self] (image, info) in
                                    guard let image = image, let info = info else { return }
                                    
                                    if let isThumbnail = info[PHImageResultIsDegradedKey] as? Bool,
                                        !isThumbnail {
                                        
                                        // TODO: Trigger photo selection event here
                                        self?.selectedPhotosSubject.onNext(image)
                                    }
        })
    }
}

// Photo library
extension PhotoCollectionViewController {
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        
        let options = PHFetchOptions()
        
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return PHAsset.fetchAssets(with: options)
    }
}

// MARK: - private method
extension PhotoCollectionViewController {
    
    /// check 相册权限
    private func checkPhotoAuthorized() {
        
        /*
         授权成功的序列可能是：.next(true)，.completed或.next(false)，.next(true)，.completed；
         授权失败的序列则是：.next(false)，.next(false)，.completed；
         */
        
        let isAuthorized = PHPhotoLibrary.isAuthorized.share()
        
        /*
         只要忽略掉事件序列中所有的false，并读到第一个true，就可以认为授权成功了
         */
        isAuthorized
            .skipWhile({ (e) -> Bool in e == false }) // skipWhile { $0 == false }, 跳过前面所有满足条件的事件, 一旦遇到不满足条件的事件，之后就不会再跳过了。
            .take(1) // 仅发送 Observable 序列中的前 n 个事件，在满足数量之后会自动 .completed
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
                
                guard let `self` = self else { return }
                
                self.photos = PhotoCollectionViewController.loadPhotos()
                self.collectionView?.reloadData()
            })
            .disposed(by: bag)
        
        /*
         失败对应的事件序列只有一种情况：.next(false)，.next(false)，.completed。因此，我们只要对事件序列中所有元素去重之后，订阅最后一个.next事件，如果是false，就可以确定是用户拒绝授权了
         */
        isAuthorized
            .distinctUntilChanged() // 用于过滤掉连续重复的事件
            .takeLast(1) // 仅发送 Observable 序列中的后 n 个事件。
            .filter { (e) -> Bool in !e } // e == false, 选择序列中所有满足条件的元素
            .subscribe(onNext: { [weak self] (_) in
                
                guard let `self` = self else { return }
                
                self.flash(title: "Cannot access your photo library",
                           message: "You can authorize access from the Settings.",
                           callback: { _ in
                            self.navigationController?.popViewController(animated: true)
                })
            })
            .disposed(by: bag)
    }
}
