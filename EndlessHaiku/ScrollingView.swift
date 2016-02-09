//
//  ScrollingView.swift
//  EndlessHaiku
//
//  Created by Thinh Luong on 1/20/16.
//  Copyright © 2016 Thinh Luong. All rights reserved.
//

import UIKit

class ScrollingView: UIView {
  
  
  // MARK: Lifecycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    loadBackground()
    loadLabels()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Properties
  var haiku: Haiku!
  var haikuLabel = UILabel()
  var authorLabel = UILabel()
  
  var translation: CGFloat = 0
  var scrollDirection = Direction.Right
  let scrollSpeed: CGFloat = 0.1
  
  enum Direction: CGFloat {
    case Left = -1, Right = 1, Up, Down
  }
  
  var mountFuji = UIImage(named: "OfflineMotivation_MountFuji")
  var farm = UIImage(named: "OfflineMotivation_Farm")
  var egypt = UIImage(named: "OfflineMotivation_Egypt")
  var america = UIImage(named: "OfflineMotivation_America")
  var india = UIImage(named: "OfflineMotivation_India")
  
  var backgroundImageIndex: Int = 0
  var backgroundImage: UIImage? {
    get {
      var randomIndex: Int
      repeat {
        randomIndex = Int(arc4random_uniform(5))
      } while randomIndex == backgroundImageIndex
      
      backgroundImageIndex = randomIndex
      
      let image: UIImage?
      
      switch backgroundImageIndex {
      case 0:
        image = mountFuji
      case 1:
        image = farm
      case 2:
        image = egypt
      case 3:
        image = america
      case 4:
        image = india
      default:
        image = mountFuji
      }
      return image
    }
  }
  
  lazy var scrollLayer: CAScrollLayer = {
    [unowned self] in
    
    let scrollLayer = CAScrollLayer()
    scrollLayer.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    scrollLayer.position = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
    scrollLayer.borderColor = UIColor.blackColor().CGColor
    scrollLayer.borderWidth = 0
    scrollLayer.scrollMode = kCAScrollHorizontally
    scrollLayer.backgroundColor = UIColor.blackColor().CGColor
    
    return scrollLayer
    }()
  
  lazy var displayLink: CADisplayLink = {
    [unowned self] in
    
    let displayLink = CADisplayLink(target: self, selector: "scrollLayerScroll")
    displayLink.frameInterval = 1
    
    return displayLink
    }()
  
  
  var quoteTextFont: CGFloat {
    get {
      
      //      var baseSize: CGFloat
      //      switch currentQuote.quote.characters.count {
      //      case 0...50:
      //        baseSize = 30
      //      case 51...100:
      //        baseSize = 24
      //      case 101...200:
      //        baseSize = 20
      //      case 201...1000:
      //        baseSize = 18
      //      default:
      //        baseSize = 30
      //      }
      //      
      //      return baseSize * fontScale
      
      return 30
    }
  }
  
  var fontScale: CGFloat {
    get {
      switch currentDevice {
      case .iPhone4:
        return 1
      case .iPhone5:
        return 1.1
      case .iPhone6:
        return 1.3
      case .iPhone6Plus:
        return 1.5
      case .iPad:
        return 2
      }
    }
  }
}

// MARK: Loading
extension ScrollingView {
  
  private func loadBackground() {
    
    if let image = mountFuji {
      let layer = CALayer()
      layer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
      layer.contents = image.CGImage
      
      self.layer.addSublayer(scrollLayer)
      scrollLayer.addSublayer(layer)
      
      displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
  }
  
  private func loadLabels() {
    
    haikuLabel = UILabel(frame: CGRect(x: bounds.size.width * 0.02, y: bounds.size.height * 0.05, width: bounds.size.width * 0.96, height: bounds.size.height * 0.75))
    haikuLabel.lineBreakMode = .ByWordWrapping
    haikuLabel.numberOfLines = 0
    haikuLabel.textAlignment = NSTextAlignment.Center
    haikuLabel.font = UIFont(name: Font.Verdana, size: 24 * fontScale)
    haikuLabel.backgroundColor = UIColor.clearColor()
    haikuLabel.textColor = UIColor.whiteColor()
    haikuLabel.shadowColor = UIColor.darkGrayColor()
    haikuLabel.shadowOffset = CGSize(width: 1, height: 1)
    
    haikuLabel.adjustsFontSizeToFitWidth = true
    haikuLabel.minimumScaleFactor = 0.2
    
    addSubview(haikuLabel)
    
    authorLabel = UILabel(frame: CGRect(x: bounds.size.width * 0.5, y: bounds.size.height * 0.8, width: bounds.size.width * 0.5, height: bounds.size.height * 0.1))
    authorLabel.lineBreakMode = .ByWordWrapping
    authorLabel.numberOfLines = 0
    authorLabel.textAlignment = NSTextAlignment.Center
    authorLabel.font = UIFont(name: Font.Verdana, size: 14 * fontScale)
    authorLabel.backgroundColor = UIColor.clearColor()
    authorLabel.textColor = UIColor.whiteColor()
    
    authorLabel.adjustsFontSizeToFitWidth = true
    authorLabel.minimumScaleFactor = 0.2
    
    addSubview(authorLabel)
    
    haikuLabel.text = "Swipe"
    authorLabel.text = ""
  }
  
}

// MARK: Scrolling
extension ScrollingView {
  func scrollLayerScroll() {
    
    if displayLink.paused == false {
      translation += scrollSpeed * scrollDirection.rawValue
      
      let newPoint = CGPoint(x: translation, y: 0)
      scrollLayer.scrollToPoint(newPoint)
    }
    
    if translation >= mountFuji!.size.width - bounds.size.width || translation <= 0 {
      
      switch scrollDirection {
      case .Left:
        scrollDirection = .Right
      case .Right:
        scrollDirection = .Left
      default:
        break
      }
      
      pauseDisplayLink()
      
      CATransaction.begin()
      let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
      fadeOutAnimation.fromValue = 1
      fadeOutAnimation.toValue = 0
      fadeOutAnimation.additive = false
      fadeOutAnimation.removedOnCompletion = false
      fadeOutAnimation.fillMode = kCAFillModeForwards
      fadeOutAnimation.beginTime = 0
      fadeOutAnimation.duration = 1.5
      
      CATransaction.setCompletionBlock {
        
        self.scrollLayer.sublayers = nil
        
        if let image = self.backgroundImage {
          let layer = CALayer()
          layer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
          
          layer.contents = image.CGImage
          self.scrollLayer.addSublayer(layer)
        }
        
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0
        fadeInAnimation.toValue = 1
        fadeInAnimation.additive = false
        fadeInAnimation.removedOnCompletion = false
        fadeInAnimation.fillMode = kCAFillModeForwards
        fadeInAnimation.beginTime = CACurrentMediaTime() + 1.8
        fadeInAnimation.duration = 1.5
        
        self.scrollLayer.addAnimation(fadeInAnimation, forKey: nil)
        
        let seconds: Double = 3
        let delay = seconds * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
          self.resumeDisplayLink()
        })
        
      }
      
      scrollLayer.addAnimation(fadeOutAnimation, forKey: nil)
      
      CATransaction.commit()
    }
  }
  
  private func pauseDisplayLink() {
    displayLink.paused = true
  }
  
  private func resumeDisplayLink() {
    displayLink.paused = false
  }
}


// MARK: Animation
extension ScrollingView {
  
  func swipe(direction: Direction, completion: (Bool)->Void) {
    
    let slideOutPosition: CGPoint
    let slideInPosition: CGPoint
    let transitionPosition: CGPoint
    
    switch direction {
    case .Left:
      slideOutPosition = CGPoint(x: -bounds.size.width, y: haikuLabel.frame.origin.y)
      slideInPosition = CGPoint(x: bounds.size.width * 0.02, y: haikuLabel.frame.origin.y)
      transitionPosition = CGPoint(x: bounds.size.width, y: haikuLabel.frame.origin.y)
    case .Right:
      slideOutPosition = CGPoint(x: bounds.size.width, y: haikuLabel.frame.origin.y)
      slideInPosition = CGPoint(x: bounds.size.width * 0.02, y: haikuLabel.frame.origin.y)
      transitionPosition = CGPoint(x: -bounds.size.width, y: haikuLabel.frame.origin.y)
    case .Up:
      slideOutPosition = CGPoint(x: haikuLabel.frame.origin.x, y: -bounds.size.height)
      slideInPosition = CGPoint(x: haikuLabel.frame.origin.x, y: bounds.size.height * 0.05)
      transitionPosition = CGPoint(x: haikuLabel.frame.origin.x, y: bounds.size.height)
    case .Down:
      slideOutPosition = CGPoint(x: haikuLabel.frame.origin.x, y: bounds.size.height)
      slideInPosition = CGPoint(x: haikuLabel.frame.origin.x, y: bounds.size.height * 0.05)
      transitionPosition = CGPoint(x: haikuLabel.frame.origin.x, y: -bounds.size.height)
    }
    
    let duration: NSTimeInterval = 0.8
    let options = UIViewAnimationOptions.CurveEaseInOut
    let delay: NSTimeInterval = 0
    
    UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
      self.haikuLabel.frame.origin = slideOutPosition
      self.haikuLabel.alpha = 0
      
      self.authorLabel.alpha = 0
      
      }, completion: {
        _ in
        
        self.haikuLabel.text = self.haiku.getHaikuLines()
        self.haikuLabel.frame.origin = transitionPosition
        self.haikuLabel.font = UIFont(name: Font.Verdana, size: self.quoteTextFont)
        
        self.authorLabel.text = self.haiku.author
        
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
          self.haikuLabel.frame.origin = slideInPosition
          self.haikuLabel.alpha = 1
          
          self.authorLabel.alpha = 1
          
          }, completion: completion)
        
    })
  }
  
  func hideCredits() {
    let duration: NSTimeInterval = 0.8
    let options = UIViewAnimationOptions.CurveEaseInOut
    let delay: NSTimeInterval = 0
    
    UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
      self.haikuLabel.alpha = 0
      self.authorLabel.alpha = 0
      
      }, completion: {
        _ in
        self.haikuLabel.text = self.haiku.getHaikuLines()
        self.haikuLabel.font = UIFont(name: Font.Verdana, size: self.quoteTextFont)
        
        self.authorLabel.text = self.haiku.author
        
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
          self.haikuLabel.alpha = 1
          self.authorLabel.alpha = 1
          
          }, completion: nil)
        
    })
  }
  
  func showCredits() {
    let duration: NSTimeInterval = 0.8
    let options = UIViewAnimationOptions.CurveEaseInOut
    let delay: NSTimeInterval = 0
    
    UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
      self.haikuLabel.alpha = 0
      self.authorLabel.alpha = 0
      
      }, completion: {
        _ in
        self.haikuLabel.text = "Arts by: Openclipart.org\n\nMusic by: Freesound.org"
        self.haikuLabel.font = UIFont(name: Font.Verdana, size: 30 * self.fontScale)
        
        self.authorLabel.text = ""
        
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
          self.haikuLabel.alpha = 1
          self.authorLabel.alpha = 1
          
          }, completion: nil)
        
    })
  }
  
}

























