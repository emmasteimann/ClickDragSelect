import UIKit
import PlaygroundSupport

class UIVC : UIViewController {
  let uiv = NewUIV()
  let boxView = UIView()
  var initialPoint = CGPoint(x: 0, y: 0)
  var currentPoint = CGPoint(x: 0, y: 0)
  var isDraggingSelectedView = false

  override func viewDidLoad() {

    super.viewDidLoad()
    self.view?.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
    self.view?.backgroundColor = UIColor.white

    uiv.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    self.view?.addSubview(uiv)


    self.view?.addSubview(boxView)
    createSomeBoxes()

    boxView.center = CGPoint(x: self.view.center.x/2, y: 100)

    let uipan = UIPanGestureRecognizer(target: self, action: #selector(self.panAround(_:)))
    self.view.addGestureRecognizer(uipan)

    let uitap = UITapGestureRecognizer(target: self, action: #selector(self.tapDown(_:)))
    self.view.addGestureRecognizer(uitap)
  }

  func createSomeBoxes() {
    let padding = 50
    let size = 30
    for x in 1...10 {
      var row = 0
      var xPos = 0
      var yPos = 0

      if x % 2 == 0 {
        row = 1
      }

      xPos = (x % 5) * padding + padding
      yPos = (padding * row) + padding

      let newUIView = SelectableView()
      newUIView.backgroundColor = UIColor.red
      newUIView.frame = CGRect(x: xPos, y: yPos, width: size, height: size)
      self.view.addSubview(newUIView)
    }
  }

  func tapDown(_ sender:UITapGestureRecognizer) {
    let location = sender.location(in: self.view)
    if let hitView = self.view.hitTest(location, with: nil) as? SelectableView {
      hitView.backgroundColor = UIColor.purple
      hitView.selected = true
      hitView.originalDragPosition = hitView.center
    } else {
      for childView in self.view.subviews {
        if let selectableView = childView as? SelectableView {
            selectableView.selected = false
            selectableView.originalDragPosition = selectableView.center
            selectableView.backgroundColor = UIColor.red
        }
      }
    }
  }

  func panAround(_ sender:UIPanGestureRecognizer) {
    let location = sender.location(in: self.view)


    switch sender.state {
      case .began:
        initialPoint = location
          if let hitView = self.view.hitTest(location, with: nil) as? SelectableView {
            self.isDraggingSelectedView = true
            hitView.backgroundColor = UIColor.purple
            if let selectableView = hitView as? SelectableView {
              selectableView.selected = true
              selectableView.originalDragPosition = selectableView.center
            }
          }

        if self.isDraggingSelectedView {
          print("dragging on selected")
        } else {
          for childView in self.view.subviews {
            if let selectableView = childView as? SelectableView {
              childView.backgroundColor = UIColor.red
                selectableView.selected = false
                selectableView.originalDragPosition = selectableView.center
            }
          }
          uiv.frame = CGRect(x: initialPoint.x, y: initialPoint.y, width: 0, height: 0)
          uiv.draw = true
          uiv.setNeedsDisplay()
        }
      case .changed:
        currentPoint = location
        let deltaX = currentPoint.x - initialPoint.x
        let deltaY = currentPoint.y - initialPoint.y

        for childView in self.view.subviews {
          if childView is UIV {} else {
            if self.isDraggingSelectedView {
              for childView in self.view.subviews {
                if let selectableView = childView as? SelectableView {
                  if selectableView.selected {
                    self.view.bringSubview(toFront: selectableView)
                    selectableView.center = CGPoint(x: selectableView.originalDragPosition.x + deltaX, y: selectableView.originalDragPosition.y + deltaY)
                  }
                }
              }
            } else {
              if childView.frame.intersects(uiv.frame) {
                childView.backgroundColor = UIColor.purple
                if let selectableView = childView as? SelectableView {
                  selectableView.selected = true
                }
              } else {
                childView.backgroundColor = UIColor.red
              }
            }
          }
        }

        uiv.frame = CGRect(x: initialPoint.x, y: initialPoint.y, width: deltaX, height: deltaY)
        uiv.setNeedsDisplay()
      default:
        for childView in self.view.subviews {
          if let selectableView = childView as? SelectableView {
            if selectableView.selected {
              selectableView.originalDragPosition = selectableView.center
            }
          }
        }
        self.isDraggingSelectedView = false
        uiv.draw = false
        uiv.setNeedsDisplay()
        break
    }
  }
}

class SelectableView : UIView {
  var selected = false
  var originalDragPosition = CGPoint(x: 0, y: 0)
}

class UIV : UIView {}

class NewUIV : UIV {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var highlightColor = UIColor.green.withAlphaComponent(0.5)
  var draw = false

  override func draw(_ rect: CGRect) {
    if draw {
      highlightColor.setFill()
      UIRectFill(rect)
    }
  }
}

let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
window.rootViewController = UIVC()
window.makeKeyAndVisible()
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = window

