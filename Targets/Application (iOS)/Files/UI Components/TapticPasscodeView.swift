//
//  TapticPasscodeView.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/8/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

extension String {
    func attribute(color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .medium), .foregroundColor: color])
    }
}

struct TapticPasscodeData {
    var data: [(IndexPath, force: Bool)] = []
    
    init() {
        
    }
    
    var isComplete: Bool {
        return data.count == 4
    }
    
    mutating func press(indexPath: IndexPath, force: Bool) {
        data.append((indexPath, force))
    }
    
    func renderLabelText() -> NSAttributedString {
        let labelText = NSMutableAttributedString()
        let emptyText = "Enter...".attribute(color: .gray)
        for (indexPath, force) in data {
            let color = force ? UIColor.red : UIColor.black
            labelText.append(String(indexPath.numberForPasscodeDot).attribute(color: color))
        }
        return labelText.string.isEmpty ? emptyText : labelText
    }
    
    func renderObfuscatedText() -> NSAttributedString {
        let labelText = NSMutableAttributedString()
        for _ in data {
            labelText.append(NSAttributedString(string: "*", attributes: [.font: UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .medium), .foregroundColor: UIColor.black]))
        }
        return labelText
    }
    
    static func == (lhs: TapticPasscodeData, rhs: TapticPasscodeData) -> Bool {
        guard lhs.isComplete && rhs.isComplete else {
            return false
        }
        
        for (element1, element2) in zip(lhs.data, rhs.data) {
            if !(element1.0 == element2.0 && element1.force == element2.force) {
                return false
            }
        }
        
        return true
    }
}

class TapticPasscodeView: UIView {
    var tapticEngine = TapticEngine()
    
    var disposeBag = DisposeBag()
    var rx_indexPathSelected = PublishSubject<(IndexPath, force: Bool)>()
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = .init()
    let passcodeRows = UIStackView()
    let saved: UILabel = .init()
    let clear: UIButton = .init()
    
    var data: TapticPasscodeData = .init()
    var savedData: TapticPasscodeData?
    
    func processData() {
        if data.isComplete {
            if let savedData = savedData {
                if savedData == data {
                    label.attributedText = "Success".attribute(color: .green)
                    label.textColor = UIColor.green
                    tapticEngine.generate(.notification(type: .success))
                } else {
                    label.attributedText = "Failure".attribute(color: .red)
                    label.textColor = UIColor.red
                    tapticEngine.generate(.notification(type: .error))
                }
                data = .init()
            } else {
                tapticEngine.generate(.notification(type: .success))
                savedData = data
                label.attributedText = "Enter...".attribute(color: .gray)
                saved.attributedText = data.renderLabelText()
                data = .init()
            }
        } else {
            if let _ = savedData {
                label.attributedText = data.renderObfuscatedText()
            } else {
                label.attributedText = data.renderLabelText()
                saved.attributedText = " ".attribute(color: .black)
            }
        }
    }

    func handlePress(indexPath: IndexPath, force: Bool) {
        data.press(indexPath: indexPath, force: force)
        processData()
    }
    
    func bind() {
        unowned let _self = self
        
        rx_indexPathSelected
            .subscribe(onNext: _self.handlePress)
            .disposed(by: disposeBag)
        
        clear.rx.tap.subscribe(onNext: { [unowned self] in
            self.data = .init()
            self.savedData = nil
            self.processData()
        }).disposed(by: disposeBag)
    }
    
    func configure() {
        configureSubviews()
        addSubviews()
        addConstraints()
        bind()
        processData()
    }
    func configureSubviews() {
        configureLabel()
        configurePasscodeRows()
        configuredSaved()
        configureClear()
    }
    
    func addConstraints() {
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.left.right.equalToSuperview()
        }
        passcodeRows.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(48)
            make.left.right.equalToSuperview()
        }
        saved.snp.makeConstraints { make in
            make.top.equalTo(passcodeRows.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
        }
        clear.snp.makeConstraints { make in
            make.top.equalTo(saved.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
    }
    
    func addSubviews() {
        addSubview(label)
        addSubview(passcodeRows)
        addSubview(saved)
        addSubview(clear)
    }
}

extension TapticPasscodeView {
    func configureLabel() {
        label.textColor = .black
        label.textAlignment = .center
    }
    
    func configurePasscodeRows() {
        passcodeRows.distribution = .equalSpacing
        passcodeRows.alignment = .center
        passcodeRows.axis = .vertical
        passcodeRows.spacing = 16
        passcodeRows.addArrangedSubview(createStackView(section: 0, numberOfItems: 3))
        passcodeRows.addArrangedSubview(createStackView(section: 1, numberOfItems: 3))
        passcodeRows.addArrangedSubview(createStackView(section: 2, numberOfItems: 3))
        passcodeRows.addArrangedSubview(createStackView(section: 3, numberOfItems: 1))
    }
    
    func configuredSaved() {
        saved.textColor = .black
        saved.textAlignment = .center
        saved.attributedText = " ".attribute(color: .black)
    }
    
    func configureClear() {
        clear.backgroundColor = .red
        clear.setTitle("Reset", for: .normal)
        clear.setTitleColor(.white, for: .normal)
        clear.layer.cornerRadius = clear.intrinsicContentSize.height / 3.5
        clear.layer.borderColor = UIColor.red.cgColor
        clear.layer.borderWidth = 1.5
    }
}

extension Reactive where Base: TapticPasscodeView {
    var indexPathSelected: ControlProperty<(IndexPath, force: Bool)> {
        return ControlProperty(values: base.rx_indexPathSelected, valueSink: base.rx_indexPathSelected)
    }
}

extension IndexPath {
    var numberForPasscodeDot: Int {
        var result = (section * 3) + (item + 1)
        result = (result == 10) ? 0 : result
        return result
    }
}

// MARK: - Helpers -

extension TapticPasscodeView {
    func createStackView(section: Int, numberOfItems: Int) -> UIStackView {
        let stackView = UIStackView()
        
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 16
        
        for item in 0..<numberOfItems {
            let view = TapticPasscodeDotView(indexPath: IndexPath(item: item, section: section), parent: self)
            stackView.addArrangedSubview(view)
        }
        
        return stackView
    }
}
