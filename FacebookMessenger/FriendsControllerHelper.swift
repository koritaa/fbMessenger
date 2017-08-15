//
//  FriendsControllerHelper.swift
//  FacebookMessenger
//
//  Created by Korita on 06.08.17.
//  Copyright © 2017 Korita. All rights reserved.
//

import Foundation
import UIKit
import CoreData
extension FriendsViewController {
    
        func setUpMessageData() -> Void {
        
        clearData ()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            let friend = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            
            createSteveMessages(context: context)
            
            friend.name = "Mark Zuckerberg"
            friend.profileImageName = "zuckprofile"
            FriendsViewController.createMessageWithText(text: "Hello Good Morning. How are you doing", friend: friend, context: context, minutesAgo: 1.0)
            
            let friendDon = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            
            friendDon.name = "Donald Trump"
            friendDon.profileImageName = "trump"
           FriendsViewController.createMessageWithText(text: "Its gonna be huuuuuugeeeee", friend: friendDon, context: context, minutesAgo: 4)
       
            
            let friendGandhi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            friendGandhi.name = "Mahatma Gandhi"
            friendGandhi.profileImageName = "gandhi"
            
            FriendsViewController.createMessageWithText(text: "Love, peace and joy", friend: friendGandhi, context: context, minutesAgo: 60*24)
            
            let friendHillary = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            friendHillary.name = "Hillary Clinton"
            friendHillary.profileImageName = "hillary_profile"
            
            FriendsViewController.createMessageWithText(text: "Please vote for me, you did for Billy", friend: friendHillary, context: context, minutesAgo: 60*24*8)
            
            do {
             try  (context.save())
            }
            catch  let err {
                print(err)
            }
            
        }
        
        loadData()
    }
    
    func createSteveMessages(context: NSManagedObjectContext) {
        
        let friendSteve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        friendSteve.name = "Steve Jobs"
        friendSteve.profileImageName = "stevePic"
        
        FriendsViewController.createMessageWithText(text: "Hello Good Morning.", friend: friendSteve, context: context, minutesAgo: 1.0)
        FriendsViewController.createMessageWithText(text: "Hello Good Morning. How are you doing?? Are you ok?", friend: friendSteve, context: context, minutesAgo: 2.0)
        FriendsViewController.createMessageWithText(text: "Hello Good Morning. How are you doing?? Are you ok? Hello???", friend: friendSteve, context: context, minutesAgo: 3.0)
         FriendsViewController.createMessageWithText(text: "Hello Good Morning. How are you doing?? Are you ok? Hello???", friend: friendSteve, context: context, minutesAgo: 3.0)
         FriendsViewController.createMessageWithText(text: "Hello Good Morning. How are you doing?? Are you ok? Hello???", friend: friendSteve, context: context, minutesAgo: 3.0)
         FriendsViewController.createMessageWithText(text: "Hello Good Morning. How are you doing?? Are you ok? Hello???", friend: friendSteve, context: context, minutesAgo: 3.0)
        
        FriendsViewController.createMessageWithText(text: "Hey I want an apple watch", friend: friendSteve, context: context, minutesAgo: 2, isSender: true)
        
        FriendsViewController.createMessageWithText(text: "Hey I want an apple watch", friend: friendSteve, context: context, minutesAgo: 2, isSender: true)
        
        FriendsViewController.createMessageWithText(text: "Hey I want an apple watch", friend: friendSteve, context: context, minutesAgo: 2, isSender: true)
        
        FriendsViewController.createMessageWithText(text: "Hey I want an apple watch", friend: friendSteve, context: context, minutesAgo: 2, isSender: true)
        FriendsViewController.createMessageWithText(text: "Hello Good Morning. How are you doing?? Are you ok? Hello???", friend: friendSteve, context: context, minutesAgo: 0)
        FriendsViewController.createMessageWithText(text: "Hey I want an apple", friend: friendSteve, context: context, minutesAgo: 2.3, isSender: true)
    }
    
   static func createMessageWithText(text: String, friend: Friend , context: NSManagedObjectContext , minutesAgo: Double , isSender: Bool = false) -> Message  {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.time = NSDate().addingTimeInterval(-minutesAgo*60)
        message.isSender = NSNumber(booleanLiteral: isSender) as! Bool
    return message
    }
    
    func clearData() -> Void {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            do {
                let entityNames = ["Friend", "Message"]

                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let objects = try(context.fetch(fetchRequest)) as? [NSManagedObject]
                    for  object in objects! {
                        context.delete(object)
                    }
                }

                try (context.save())
            }
            catch let err {
                print(err)
            }
        }
        
    }
    
    func loadData() -> Void {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if  let friends = fetchFriends() {
            messages = [Message]()
            for friend in friends {
                
                if let context = delegate?.persistentContainer.viewContext {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
                    fetchRequest.predicate = NSPredicate(format: "friend.name=%@", friend.name!)
                    fetchRequest.fetchLimit = 1
                    do {
                        let fetchedMessages = try  (context.fetch(fetchRequest)) as? [Message]
                        messages?.append(contentsOf: fetchedMessages!)
                    }
                    catch  let err {
                        print(err)
                    }
                    
              }
                messages = messages?.sorted(by: {$0.time!.compare($1.time! as Date) == .orderedDescending})
        }
        
     }
 }
    
    func fetchFriends() -> [Friend]? {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            
            do {
               return try(context.fetch(fetchRequest)) as? [Friend]
            }
            catch let err {
                print(err)
            }
            
    }
        return nil
    
    }
}
