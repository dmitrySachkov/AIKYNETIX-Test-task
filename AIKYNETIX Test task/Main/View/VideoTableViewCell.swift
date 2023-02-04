//
//  VideoTableViewCell.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 03.02.2023.
//

import UIKit
import SnapKit

class VideoTableViewCell: UITableViewCell {
    
    private(set) lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    private(set) lazy var dateLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI element
    private func setupUI() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(dateLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(24)
        }
    }
    
    //MARK: - Set cell element
    func configureCell(by title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
    }
}
