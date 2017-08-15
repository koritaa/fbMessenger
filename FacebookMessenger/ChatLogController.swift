//
//  ChatLogController.swift
//  FacebookMessenger
//
//  Created by Korita on 07.08.17.
//  Copyright © 2017 Korita. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    private let cellId = "cell"
    var friend : Friend? {
        didSet {
            navigationItem.title = friend?.name
        }
    }

    var bottomConst: NSLayoutConstraint?
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor(colorLiteralRed: 0, green: 137/255, blue: 249/255, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    func handleSend() -> Void {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        FriendsViewController.createMessageWithText(text: inputTextField.text!, friend: friend!, context: context, minutesAgo: 0, isSender: true)
        
        do {
          try context.save()
            inputTextField.text = ""
        } catch let err {
            print(err)
        }
    }
    
    func simulate() -> Void {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
    FriendsViewController.createMessageWithText(text: "Heyyyaa", friend: friend!, context: context, minutesAgo: 7, isSender: false)
        
        do {
         try context.save()
            }
         catch let err {
            print(err)
        }
    }
    var blockOperations = [BlockOperation]()
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", (self.friend?.name!)!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
       let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
            
//            collectionView?.scrollToItem(at: newIndexPath!, at: .bottom, animated: true)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for  operation in self.blockOperations {
                operation.start()
            }
        }, completion: {
            (completed) in
            let item = (self.fetchedResultsController.sections?[0].numberOfObjects)! - 1
            let indexPath = NSIndexPath(item: item, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
            print(fetchedResultsController.sections?[0].numberOfObjects)
        }
        catch let err {
            print(err)
        }
      
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatLogCell.self, forCellWithReuseIdentifier: cellId)
        tabBarController?.tabBar.isHidden = true
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        self.setUpInputComponents()
        
        bottomConst = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConst!)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    
    func handleKeyboardNotification(notification: NSNotification) -> Void {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            if isKeyboardShowing {
                 bottomConst?.constant = -(keyboardFrame?.height)!
            }
            else {
                bottomConst?.constant = 0
            }
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
              self.view.layoutIfNeeded()
            }, completion: {
            (completed) in
                
                if isKeyboardShowing {
                    
                    let item = (self.fetchedResultsController.sections?[0].numberOfObjects)! - 1
                    let lastMessageIndexPath = NSIndexPath(item: item, section: 0)
                    self.collectionView?.scrollToItem(at: lastMessageIndexPath as IndexPath, at: .bottom, animated: true)

                }
            })
        }
    }
    
    private func setUpInputComponents() -> Void {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField , sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as!
        ChatLogCell
        let message = fetchedResultsController.object(at: indexPath) as! Message
        
        cell.messageTextView.text = message.text
        
        if let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            cell.profileImageView.image = UIImage(named: profileImageName)
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with:size , options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
            
            if !message.isSender {
                cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.bubbleView.frame = CGRect(x: 48 - 12, y: -4, width: estimatedFrame.width + 16 + 24, height: estimatedFrame.height + 26)
                cell.profileImageView.isHidden = false
                cell.messageTextView.textColor = UIColor.black
                cell.bubbleTailView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleTailView.image = ChatLogCell.grayBubbleImage
            }
            else {
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.bubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 24 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                cell.profileImageView.isHidden = true
                cell.messageTextView.textColor = UIColor.white
                cell.bubbleTailView.tintColor = UIColor(colorLiteralRed: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.bubbleTailView.image = ChatLogCell.blueBubbleImage
            }
        
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = fetchedResultsController.object(at: indexPath) as! Message
        
        if let messageText = message.text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with:size , options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
      return CGSize(width: view.frame.width, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
    
   
}

class ChatLogCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Sample"
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        return textView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22,left: 26,bottom: 22,right: 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22,left: 26,bottom: 22,right: 26)).withRenderingMode(.alwaysTemplate)
    
    let bubbleTailView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(white: 0.95, alpha: 1)
        return imageView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setUpViews() {
        super.setUpViews()
        addSubview(bubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addConstraintsWithFormat(format:  "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
        profileImageView.backgroundColor = UIColor.red
        bubbleView.addSubview(bubbleTailView)
        bubbleView.addConstraintsWithFormat(format:"H:|[v0]|" , views: bubbleTailView)
        bubbleView.addConstraintsWithFormat(format:"V:|[v0]|" , views: bubbleTailView)
    }
    
   
}
