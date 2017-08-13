//
//  ChatLogController.swift
//  FacebookMessenger
//
//  Created by Korita on 07.08.17.
//  Copyright © 2017 Korita. All rights reserved.
//

import Foundation
import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    private let cellId = "cell"
    var friend : Friend? {
        didSet {
            navigationItem.title = friend?.name
            
            messages = friend?.messages?.allObjects as? [Message]
            messages = messages?.sorted(by: {$0.time!.compare($1.time! as Date) == .orderedAscending})
        }
    }
    var messages: [Message]?
    let messageInputContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatLogCell.self, forCellWithReuseIdentifier: cellId)
        tabBarController?.tabBar.isHidden = true
        collectionView?.addSubview(messageInputContainerView)
        collectionView?.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        collectionView?.addConstraintsWithFormat(format: "V:|[v0]|", views: messageInputContainerView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfMessages =  (messages?.count){
            return numberOfMessages
        }
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as!
        ChatLogCell
        cell.messageTextView.text = messages?[indexPath.item].text
        
        if let message = messages?[indexPath.item],
            let messageText = message.text, let profileImageName = message.friend?.profileImageName {
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
        if let messageText = messages?[indexPath.item].text {
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
        return textView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.90, alpha: 1)
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
