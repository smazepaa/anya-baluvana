import UIKit
import SnapKit
import Combine

final class UserViewController: UIViewController {
    
    private let viewModel: UserViewModel
    private let loadingView: UIActivityIndicatorView
    private let tableView: UITableView
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        self.loadingView = UIActivityIndicatorView(style: .large)
        self.tableView = UITableView(frame: .zero, style: .grouped)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupViewModelPublishers()
    }

    private func setupView() {
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(loadingView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        loadingView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loadingView.isHidden = true
    }
    
    private func setupViewModelPublishers() {
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                self?.showLoading(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$user
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func showLoading(_ show: Bool) {
        loadingView.isHidden = !show
        tableView.isHidden = show

        if show {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.user == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as? UserCell,
              let user = viewModel.user else {
            return UITableViewCell()
        }
        
        cell.setupCell(with: user)
        
        cell.onEditPhoneTapped = { [weak self] in
            self?.presentEditPhoneNumberAlert(for: user)
        }
        
        return cell
    }
    
    private func presentEditPhoneNumberAlert(for user: User) {
        let alertController = UIAlertController(title: "Edit Phone Number", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = user.phoneNumber
            textField.keyboardType = .phonePad
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let newPhoneNumber = alertController.textFields?.first?.text else { return }
            
            self.viewModel.updateUser(phoneNumber: newPhoneNumber)
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
}
