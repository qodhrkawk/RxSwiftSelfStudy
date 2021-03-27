//
//  ViewController.swift
//  DriverPractice
//
//  Created by Yunjae Kim on 2021/03/27.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

enum MyError: Error {
    case error
}

class ViewController: UIViewController {
    
    let textLabel = UILabel().then {
        $0.text = "RxKindergarten"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    let textField = UITextField().then {
        $0.placeholder = "input text"
        $0.borderStyle = .line
    }
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        
        textField.rx.text
            .bind(to: textLabel.rx.text)
            .disposed(by: bag)
        
        let result = textField.rx.text.asDriver()
            .flatMapLatest {
                self.checkText(value: $0)
                    .asDriver(onErrorJustReturn: false)
            }
    
        result
            .map{ $0 ? UIColor.black : UIColor.red}
            .drive(textLabel.rx.textColor)
            .disposed(by: bag)
    }

    func setupUI() {
        view.addSubview(textLabel)
        view.addSubview(textField)
        setupConstraints()
    }
    
    func setupConstraints() {
        textLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(200)
            $0.centerX.equalToSuperview()
        }
        textField.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
        }
        
    }
    
    func checkText(value : String?) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            
            if let str = value {
                if str.count > 5 {
                    observer.onError(MyError.error)
                    return Disposables.create()
                }
            }
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}

