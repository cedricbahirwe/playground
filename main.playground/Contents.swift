//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class ViewController: UIViewController {
    
    var animator: UIDynamicAnimator?
    
    var origins: [(String, CGPoint)] = []
    
    let range: ClosedRange<CGFloat> = 0.0...255.0
    
    var message = "This is cedric trying to animate the components with gravity"
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        animation()
    }
    
    
    func animation() {
        guard animator == nil else { return }
        
        // 1: split the message up into words
        let words = message.components(separatedBy: " ")
        
        
        // 2: create an empty array of labels
        var labels = [UILabel]()
        
        // 3: convert each word into a label
        for (index, word) in words.enumerated() {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .title1)
            
            // 4: position the labels one above the other
            label.center = CGPoint(x: view.frame.midX/2, y: 50 + CGFloat(30 * index))
            label.text = word
            label.isUserInteractionEnabled = true
            label.sizeToFit()
            label.textColor = UIColor(red: .random(in: range)/255, green: .random(in: range)/255, blue: .random(in: range)/255, alpha: 1)

            // MARK:  A. Store the original positions of each label before appling `UIDynamicAnimator`
            self.origins.append((label.text!, label.center))
           
            // MARK: Apply Pan Gesture to each label
            addPanGesture(sender: label)
            
            view.addSubview(label)
            labels.append(label)
        }
        
        // 5: create a gravity behaviour for our labels
        let gravity = UIGravityBehavior(items: labels)
        animator = UIDynamicAnimator(referenceView: view)
        animator?.addBehavior(gravity)
        //
        //        // 6: create a collision behavior for our labels
        let collisions = UICollisionBehavior(items: labels)
        //
        //        // 7: give some boundaries for the collisions
        collisions.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collisions)
    }
    
    func addPanGesture(sender: UILabel) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(sender:)))
        sender.addGestureRecognizer(pan)
        
    }
    
    // Animate each label with a pan gesture
    @objc func didPan(sender: UIPanGestureRecognizer) {
        let fileView = sender.view!
        let translation = sender.translation(in: self.view)
        
        
        switch sender.state {
        case .began, .changed:
            fileView.center = CGPoint(x: translation.x + fileView.center.x, y: translation.y + fileView.center.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
        case .ended :
            if fileView.isKind(of: UILabel.self) == true {
                let label  = fileView as! UILabel
                if let element = self.origins.first(where: {  $0.0 == label.text }) {
                    UIView.animate(withDuration: 0.6) {
                        fileView.center = element.1
                        UIView.animate(withDuration: 0.4, animations: {
                            fileView.transform = .identity
                        }, completion: {
                            completed in
                            // Set white color to label when finish animating
                            for subview in self.view.subviews {
                                if subview.isKind(of: UILabel.self) == true {
                                    let label  = subview as! UILabel
                                    if label.text == element.0 {
                                        UIView.animate(withDuration: 0.4) {
                                            label.textColor = .white
                                        }
                                    }
                                }
                            }
                            
                            self.origins.removeAll(where: { $0 == element })
                            
                            
                            // Set white color to all labels when animation finishes
//                            if self.origins.count == 0 {
//                                for subview in self.view.subviews {
//                                    if subview.isKind(of: UILabel.self) == true {
//                                        let label  = subview as! UILabel
//                                        UIView.animate(withDuration: 0.4) {
//                                            label.textColor = .white
//                                        }
//                                    }
//                                }
//                            }
                        })
                    }
                }
            }
            
        default:
            break
        }
        
    }
}


// Present the view controller in the Live View window
PlaygroundPage.current.liveView = ViewController()
