import Foundation
import UIKit
import SnapKit

final class UserCell: UITableViewCell {

    private let topContainer: UIView = {
        let view = UIView()
        return view
    }()

    private let imagePlaceHolder: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    private let menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.identifier)
        return tableView
    }()

    private let bottomContainer: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        button.layer.cornerRadius = 10
        button.contentHorizontalAlignment = .left
        return button
    }()

    private let deliveryStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Become a courier"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let deliveryDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Earn money on your schedule"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let courierImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "man")
        imageView.tintColor = .systemRed
        return imageView
    }()

    private let menuItems: [(icon: String, title: String)] = [
        ("creditcard", "Payment"),
        ("tag", "Promo codes"),
        ("person", "Profile"),
        ("gear", "Settings"),
        ("hand.raised", "Privacy"),
        ("info.circle", "About"),
        ("questionmark.circle", "Support")
    ]

    public static let identifier = "user"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        phoneLabel.text = nil
        imagePlaceHolder.image = nil
    }

    private func setupView() {
        backgroundColor = .white
        
        contentView.addSubview(topContainer)
        topContainer.addSubview(imagePlaceHolder)
        topContainer.addSubview(nameLabel)
        topContainer.addSubview(phoneLabel)
        topContainer.addSubview(editButton)

        editButton.addTarget(self, action: #selector(editPhoneTapped), for: .touchUpInside)

        contentView.addSubview(menuTableView)
        menuTableView.dataSource = self
        menuTableView.delegate = self

        contentView.addSubview(bottomContainer)
        bottomContainer.addSubview(deliveryStatusLabel)
        bottomContainer.addSubview(deliveryDescriptionLabel)
        bottomContainer.addSubview(courierImageView)
        
        bottomContainer.addTarget(self, action: #selector(becomeCourierTapped), for: .touchUpInside)
    }

    private func setupLayout() {
        topContainer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(100)
        }

        imagePlaceHolder.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview().offset(-10)
            $0.width.height.equalTo(80)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(imagePlaceHolder.snp.trailing).offset(15)
            $0.top.equalTo(imagePlaceHolder.snp.top).offset(15)
            $0.trailing.lessThanOrEqualToSuperview().inset(10)
        }

        phoneLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
        }

        editButton.snp.makeConstraints {
            $0.leading.equalTo(phoneLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(phoneLabel)
        }

        menuTableView.snp.makeConstraints {
            $0.top.equalTo(topContainer.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(menuItems.count * 50)
        }

        bottomContainer.snp.makeConstraints {
            $0.top.equalTo(menuTableView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(80)
            $0.bottom.equalToSuperview().inset(15)
        }

        deliveryStatusLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualTo(courierImageView.snp.leading).offset(-10)
        }

        deliveryDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(deliveryStatusLabel.snp.bottom).offset(5)
            $0.leading.equalTo(deliveryStatusLabel)
            $0.trailing.lessThanOrEqualTo(courierImageView.snp.leading).offset(-10)
        }

        courierImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(60)
        }
    }

    var onEditPhoneTapped: (() -> Void)?

    @objc private func editPhoneTapped() {
        onEditPhoneTapped?()
    }
    
    var onBecomeCourierTapped: (() -> Void)?

    @objc private func becomeCourierTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.bottomContainer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.bottomContainer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            }
        }
        
        if let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        onBecomeCourierTapped?()
    }

    func setupCell(with user: User) {
        nameLabel.text = user.name
        phoneLabel.text = user.phoneNumber
        imagePlaceHolder.image = user.avatar
    }
}

extension UserCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.identifier, for: indexPath) as? MenuCell {
            let item = menuItems[indexPath.row]
            cell.configure(with: item.icon, title: item.title)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected: \(menuItems[indexPath.row].title)")
    }
}

class MenuCell: UITableViewCell {
    static let identifier = "MenuCell"

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    func configure(with icon: String, title: String) {
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = .gray
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupLayout() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(15)
            $0.centerY.equalToSuperview()
        }
    }
}
