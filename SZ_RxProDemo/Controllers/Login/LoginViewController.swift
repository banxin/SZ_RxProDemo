//
//  LoginViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/19.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import RxSwift
import SVProgressHUD

/// 登录
class LoginViewController: UIViewController {
    
    private let bag = DisposeBag()
    
    private lazy var loginView: LoginView = LoginView()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        handleRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        
        print("LoginViewController releace")
    }
}

// MARK: - UI
extension LoginViewController {
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(loginView)
        
        loginView.snp.makeConstraints { (make) in
            
            if #available(iOS 11.0, *) {
                
                make.top.bottom.equalTo(view.safeAreaLayoutGuide)
                
            } else {
                
                make.top.bottom.equalTo(view)
            }
            
            make.left.right.equalTo(view)
        }
    }
}

// MARK: - UI
extension LoginViewController {
    
    private func handleRx() {
        
        loginView.signedIn
            .showHUD(when: .nextOrSuccess, with: "正在登录...", userInteractionEnabled: false)
            .subscribe(onNext: { [unowned self] _ in
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(floatLiteral: 1.5)) {
                    
                    HUD.dismiss()
                    
                    TextToast.showToast(message: "登录成功...")
                    
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: bag)
    }
}
