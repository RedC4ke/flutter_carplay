//
//  FCPListItem.swift
//  flutter_carplay
//
//  Created by Oğuzhan Atalay on 21.08.2021.
//

import CarPlay

@available(iOS 14.0, *)
class FCPListItem {
  private(set) var _super: CPListItem?
  private(set) var elementId: String
  private var text: String
  private var detailText: String?
  private var isOnPressListenerActive: Bool = false
  private var completeHandler: (() -> Void)?
  private var image: String?
  private var playbackProgress: CGFloat?
  private var isPlaying: Bool?
  private var playingIndicatorLocation: CPListItemPlayingIndicatorLocation?
  private var accessoryType: CPListItemAccessoryType?
  private var accessoryIcon: String?
  
  init(obj: [String : Any]) {
    self.elementId = obj["_elementId"] as! String
    self.text = obj["text"] as! String
    self.detailText = obj["detailText"] as? String
    self.isOnPressListenerActive = obj["onPress"] as? Bool ?? false
    self.image = obj["image"] as? String
    self.playbackProgress = obj["playbackProgress"] as? CGFloat
    self.isPlaying = obj["isPlaying"] as? Bool
    self.setPlayingIndicatorLocation(fromString: obj["playingIndicatorLocation"] as? String)
    self.setAccessoryType(fromString: obj["accessoryType"] as? String)
    self.accessoryIcon = obj["accessoryIcon"] as? String
  }
  
  var get: CPListItem {
    let listItem = CPListItem.init(text: text, detailText: detailText)
    listItem.handler = ((CPSelectableListItem, @escaping () -> Void) -> Void)? { selectedItem, complete in
      if self.isOnPressListenerActive == true {
        DispatchQueue.main.async { [self] in
          self.completeHandler = complete
          FCPStreamHandlerPlugin.sendEvent(type: FCPChannelTypes.onListItemSelected,
                                           data: ["elementId": self.elementId])
        }
      } else {
        complete()
      }
    }
    if image != nil {
      UIGraphicsBeginImageContext(CGSize.init(width: 100, height: 100))
      let emptyImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      listItem.setImage(emptyImage)
      DispatchQueue.global(qos: .background).async { [self] in
        let uiImage = (self.image != nil && !self.image!.isEmpty) ? UIImage().fromCorrectSource(name: self.image ?? "") : nil
        DispatchQueue.main.async {
            listItem.setImage(uiImage)
        }
      }
    }
    if playbackProgress != nil {
      listItem.playbackProgress = playbackProgress ?? 0
    }
    if isPlaying != nil {
      listItem.isPlaying = isPlaying ?? false
    }
    if playingIndicatorLocation != nil {
        listItem.playingIndicatorLocation = playingIndicatorLocation ?? CPListItemPlayingIndicatorLocation.trailing
    }
    if accessoryType != nil {
        listItem.accessoryType = accessoryType ?? CPListItemAccessoryType.none
    }
    if accessoryIcon != nil {
        DispatchQueue.global(qos: .background).async { [self] in
            let uiImage = (self.accessoryIcon != nil && !self.accessoryIcon!.isEmpty) ? UIImage(systemName: self.accessoryIcon!) : nil
            let resizedImage = uiImage?.resizeImageTo(size: CGSize.init(width: CPListItem.maximumImageSize.width / 2, height: CPListItem.maximumImageSize.height / 2) )
            DispatchQueue.main.async {
                listItem.setAccessoryImage(resizedImage)
            }
        }
    }
    self._super = listItem
    return listItem
  }
  
  public func stopHandler() {
    guard self.completeHandler != nil else {
      return
    }
    self.completeHandler?()
    self.completeHandler = nil
  }
  
    public func update(text: String?, detailText: String?, image: String?, playbackProgress: CGFloat?, isPlaying: Bool?, playingIndicatorLocation: String?, accessoryType: String?, accessoryIcon: String?) {
    if text != nil {
      self._super?.setText(text ?? "")
      self.text = text ?? ""
    }
    if detailText != nil {
      self._super?.setDetailText(detailText)
      self.detailText = detailText
    }
    // Updated to include nil value
    DispatchQueue.global(qos: .background).async { [self] in
      let uiImage = (image != nil && !image!.isEmpty) ? UIImage().fromCorrectSource(name: image ?? "") : nil
      DispatchQueue.main.async {
          self._super?.setImage(uiImage)
      }
      self.image = image
    }
    if playbackProgress != nil {
        self._super?.playbackProgress = playbackProgress ?? 0
      self.playbackProgress = playbackProgress
    }
    if isPlaying != nil {
      self._super?.isPlaying = isPlaying ?? false
      self.isPlaying = isPlaying
    }
    if playingIndicatorLocation != nil {
      self.setPlayingIndicatorLocation(fromString: playingIndicatorLocation)
      if self.playingIndicatorLocation != nil {
          self._super?.playingIndicatorLocation = self.playingIndicatorLocation ?? CPListItemPlayingIndicatorLocation.trailing
      }
    }
    if accessoryType != nil {
      self.setAccessoryType(fromString: accessoryType)
      if self.accessoryType != nil {
          self._super?.accessoryType = self.accessoryType ?? CPListItemAccessoryType.none
      }
    }
    if accessoryIcon != nil {
        DispatchQueue.global(qos: .background).async { [self] in
            let uiImage = (self.accessoryIcon != nil && !self.accessoryIcon!.isEmpty) ? UIImage(systemName: self.accessoryIcon!) : nil
            let resizedImage = uiImage?.resizeImageTo(size: CPListItem.maximumImageSize)
            DispatchQueue.main.async {
                self._super?.setAccessoryImage(resizedImage)
            }
        }
    }
  }
  
  private func setPlayingIndicatorLocation(fromString: String?) {
    if fromString == "leading" {
      self.playingIndicatorLocation = CPListItemPlayingIndicatorLocation.leading
    } else if fromString == "trailing" {
      self.playingIndicatorLocation = CPListItemPlayingIndicatorLocation.trailing
    }
  }
  
  private func setAccessoryType(fromString: String?) {
    if fromString == "cloud" {
      self.accessoryType = CPListItemAccessoryType.cloud
    } else if fromString == "disclosureIndicator" {
      self.accessoryType = CPListItemAccessoryType.disclosureIndicator
    } else {
      self.accessoryType = CPListItemAccessoryType.none
    }
  }
}
