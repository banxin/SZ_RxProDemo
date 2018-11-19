//
//  LoginView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/19.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

typealias LoginInfo = (account: String, password: String)

/// 登录 view
class LoginView: UIView {

    // MARK: - Public Properties
    
    var signedIn: Observable<LoginInfo> {
        
        return loginButton.rx.tap
                .throttle(1, scheduler: MainScheduler.instance)
                .do(onNext: {
                    
                    self.hideKeyboard()
                })
                .debug()
                .map { _ in
                    
                    LoginInfo(self.accountTextField.text!, self.passwordTextField.text!)
                }
    }
    
    // MARK: - Private Properties
    
    private let bag = DisposeBag()
    
    // 登录 label
    private lazy var loginLabel = UILabel(title: "Login", fontSize: 30, color: UIColor.colorWithHex(hexString: "ed3a4a"))
    // 账号
    private lazy var accountTextField = UITextField()
    // 密码
    private lazy var passwordTextField = UITextField()
    // 密码是否可见按钮
    private lazy var eyeButton = UIButton()
    // 登录按钮
    private lazy var loginButton = UIButton()
    // 线条 1
    private lazy var lineView1 = UIView()
    // 线条 2
    private lazy var lineView2 = UIView()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI()
        layoutSubViews()
        handleRx()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        hideKeyboard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        print("LoginView release")
    }
}

// MARK: - UI
extension LoginView {
    
    private func setupUI() {
        
        loginLabel.textAlignment = .center
        loginLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        addSubview(loginLabel)
        
        accountTextField.placeholder = "请输入邮箱"
        accountTextField.font = UIFont.systemFont(ofSize: 14)
        accountTextField.clearButtonMode = .whileEditing
        accountTextField.autocorrectionType = .no
        accountTextField.autocapitalizationType = .none
        
        addSubview(accountTextField)
        
        lineView1.backgroundColor = UIColor(hex: 0xE8E8E8)
        
        addSubview(lineView1)
        
        passwordTextField.placeholder = "请输入密码"
        passwordTextField.font = UIFont.systemFont(ofSize: 14)
        passwordTextField.keyboardType = .namePhonePad
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.isSecureTextEntry = true
        
        addSubview(passwordTextField)
        
        eyeButton.setImage(UIImage(named: "login_eye_off"), for: .normal)
        eyeButton.setImage(UIImage(named: "login_eye_on"), for: .selected)
        
        addSubview(eyeButton)
        
        lineView2.backgroundColor = UIColor(hex: 0xE8E8E8)
        
        addSubview(lineView2)
        
        loginButton.setTitle("登 录", for: .normal)
        loginButton.backgroundColor = UIColor.colorWithHex(hexString: "ed3a4a")
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loginButton.layer.cornerRadius = 5
        
        addSubview(loginButton)
    }
    
    private func layoutSubViews() {
        
        loginLabel.snp.makeConstraints { (make) in
            
            make.centerX.equalToSuperview()
            make.top.equalTo(110)
        }
        
        lineView1.snp.makeConstraints { (make) in
            
            make.top.equalTo(249)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(1)
        }
        
        accountTextField.snp.makeConstraints { (make) in
            
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.bottom.equalTo(lineView1.snp.bottom).offset(-12)
        }
        
        lineView2.snp.makeConstraints { (make) in
            
            make.top.equalTo(lineView1).offset(45)
            make.left.size.equalTo(lineView1)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            
            make.left.equalTo(self.accountTextField)
            make.right.equalTo(-60)
            make.bottom.equalTo(self.lineView2.snp.bottom).offset(-12)
        }
        
        eyeButton.snp.makeConstraints { (make) in
            
            make.right.equalTo(self.accountTextField)
            make.centerY.equalTo(self.passwordTextField.snp.centerY)
        }
        
        loginButton.snp.makeConstraints { (make) in
            
            make.top.equalTo(self.lineView2.snp.bottom).offset(20)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(40)
        }
    }
}

// MARK: - private method
extension LoginView {
    
    private func handleRx() {
        
        eyeButton.rx.tap.map { [unowned self] _ in
            return !self.eyeButton.isSelected
            }
            .subscribe(onNext: { [unowned self] isSelected in
                self.eyeButton.isSelected = isSelected
                self.passwordTextField.isSecureTextEntry = !isSelected
                /// fix:明暗文切换导致光标位置不正确
                let temp = self.passwordTextField.text
                self.passwordTextField.text = nil
                self.passwordTextField.text = temp
            })
            .disposed(by: bag)
        
        let accountObservable  = accountTextField.rx.text.orEmpty
        let passwordObservable = passwordTextField.rx.text.orEmpty
        
        // 账号 20 位
        accountObservable.map { $0.left(to: 20) }
            .bind(to: accountTextField.rx.text)
            .disposed(by: bag)
        
        // 密码 20 位
        passwordObservable.map { $0.left(to: 20) }
            .bind(to: passwordTextField.rx.text)
            .disposed(by: bag)
        
        let sendEnabled = Observable.combineLatest(accountObservable, passwordObservable) { !$0.isEmpty && !$1.isEmpty }
        
        sendEnabled
            .share()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] valid in
                
                guard let `self` = self else { return }
                
                self.loginButton.isEnabled = valid
                self.loginButton.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: bag)
        
        // bind 形式
//        sendEnabled.bind(to: self.loginButton.rx.isEnabled).disposed(by: bag)
//        sendEnabled.map { $0 ? 1.0 : 0.5 }.bind(to: self.loginButton.rx.alpha).disposed(by: bag)
        
        // driver 形式
        
//        let sendEnabledDriver = Observable.combineLatest(accountObservable, passwordObservable) {
//
//            !$0.isEmpty && !$1.isEmpty
//        }
//        .share()
//        .asDriver(onErrorJustReturn: false)
//
//        sendEnabledDriver.drive(self.loginButton.rx.isEnabled).disposed(by: bag)
//        sendEnabledDriver.map { $0 ? 1.0 : 0.5 }.drive(self.loginButton.rx.alpha).disposed(by: bag)
    }
    
    private func hideKeyboard() {
        
        accountTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}
