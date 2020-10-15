//
//  Message.swift
//  ChatApp
//
//  Created by Ahmed on 10/13/20.
//  Copyright © 2020 Ahmed. All rights reserved.
//

import Firebase
import MessageKit
import FirebaseFirestore

struct Message: MessageType {
  let id: String?
  let content: String
  let sentDate: Date
  let sender: SenderType
  
  var kind: MessageKind {
    if let image = image {
        return .photo(image as! MediaItem)
    } else {
      return .text(content)
    }
  }
  
  var messageId: String {
    return id ?? UUID().uuidString
  }
  
  var image: UIImage? = nil
  var downloadURL: URL? = nil
  
  init(user: User, content: String) {
    sender = Sender(senderId: user.uid, displayName: AppSettings.displayName)
    self.content = content
    sentDate = Date()
    id = nil
  }
  
  init(user: User, image: UIImage) {
    sender = Sender(senderId: user.uid, displayName: AppSettings.displayName)
    self.image = image
    content = ""
    sentDate = Date()
    id = nil
  }
  
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    
    //    let sentDate = data["created"] as? Date ?? Date()
    //    print(sentDate)
    //    guard let sentDate = data["created"] as? Date else {
    //      return nil
    //    }
    guard let senderID = data["senderID"] as? String  else {
        return nil
    }
    guard let senderName = data["senderName"] as? String else {
        return nil
    }
    guard let sentDate = data["created"] as? Timestamp else {
        return nil
    }
    id = document.documentID

//    self.sentDate = sentDate
    self.sentDate = sentDate.dateValue()
    sender = Sender(senderId: senderID, displayName: senderName)
    
    if let content = data["content"] as? String {
      self.content = content
      downloadURL = nil
    } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
      downloadURL = url
      content = ""
    } else {
      return nil
    }
  }
  
}

extension Message: DatabaseRepresentation {
  
  var representation: [String : Any] {
    var rep: [String : Any] = [
      "created": sentDate,
      "senderID": sender.senderId,
      "senderName": sender.displayName
    ]
    
    if let url = downloadURL {
      rep["url"] = url.absoluteString
    } else {
      rep["content"] = content
    }
    
    return rep
  }
  
}

extension Message: Comparable {
  
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }
  
}
