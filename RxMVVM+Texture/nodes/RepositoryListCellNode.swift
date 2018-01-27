import Foundation
import AsyncDisplayKit
import RxSwift
import RxASControlEvent
import RxCocoa

class RepositoryListCellNode: ASCellNode {
    typealias Node = RepositoryListCellNode
    private weak var viewModel: RepositoryViewModel?
    private let disposeBag = DisposeBag()
    
    struct Attribute {
        static let placeHolderColor: UIColor = UIColor.gray.withAlphaComponent(0.2)
    }
    
    lazy var userProfileNode = { () -> ASNetworkImageNode in
        let node = ASNetworkImageNode()
        node.style.preferredSize = CGSize(width: 50.0, height: 50.0)
        node.cornerRadius = 25.0
        node.clipsToBounds = true
        node.placeholderColor = Attribute.placeHolderColor
        node.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        node.borderWidth = 0.5
        return node
    }()
    
    lazy var usernameNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    lazy var descriptionNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    lazy var statusNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    init(viewModel: RepositoryViewModel) {
        super.init()
        self.viewModel = viewModel
        self.selectionStyle = .none
        self.backgroundColor = .white
        self.automaticallyManagesSubnodes = true
        
        // bind viewmodel
        userProfileNode.rx.event(.touchUpInside).subscribe(onNext: { [weak self] _ in
            self?.viewModel?.didTapUserProfile.onNext(())
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.profileURL?.subscribe(onNext: { [weak self] url in
            self?.userProfileNode.setURL(url, resetToDefault: true)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.openUserProfile?
            .subscribe(onNext: { [weak self] _ in
                let viewController = self?.closestViewController as? RepositoryViewController
                viewController?.openUserProfile(indexPath: self?.indexPath)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.username?.subscribe(onNext: { [weak self] username in
            self?.usernameNode.attributedText = NSAttributedString(string: username ?? "Unknown",
                                                     attributes: Node.usernameAttributes)
        }).disposed(by: self.disposeBag)

        
        self.viewModel?.desc?.subscribe(onNext: { [weak self] desc in
            guard let `desc` = desc else { return }
            self?.descriptionNode.attributedText = NSAttributedString(string: desc,
                                                     attributes: Node.descAttributes)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.status?.subscribe(onNext: { [weak self] status in
            guard let `status` = status else { return }
            self?.statusNode.attributedText = NSAttributedString(string: status,
                                                     attributes: Node.statusAttributes)
        }).disposed(by: self.disposeBag)

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentLayout = contentLayoutSpec()
        contentLayout.style.flexShrink = 1.0
        
        let stackLayout = ASStackLayoutSpec(direction: .horizontal,
                                            spacing: 10.0,
                                            justifyContent: .start,
                                            alignItems: .center,
                                            children: [userProfileNode,
                                                       contentLayout])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0,
                                                      left: 10.0,
                                                      bottom: 10.0,
                                                      right: 10.0),
                                 child: stackLayout)
    }
    
    func contentLayoutSpec() -> ASLayoutSpec {
        let elements = [self.usernameNode,
                        self.descriptionNode,
                        self.statusNode].filter { $0.attributedText != nil }
        
        
        return ASStackLayoutSpec(direction: .vertical,
                                 spacing: 5.0,
                                 justifyContent: .spaceAround,
                                 alignItems: .stretch,
                                 children: elements)
    }
    
}

extension RepositoryListCellNode {
    static var usernameAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20.0)]
    }
    
    static var descAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)]
    }

    static var statusAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.gray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0)]
    }
}