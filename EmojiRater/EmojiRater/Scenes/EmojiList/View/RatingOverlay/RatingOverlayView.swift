import UIKit

final class RatingOverlayView: UIView {
  var blurView: UIVisualEffectView?
  var animator: UIViewPropertyAnimator?
  private var overlaySnapshot: UIView?
  private var ratingStackView: UIStackView?
  
  func updateAppearance(forPreviewProgress progress: CGFloat) {
    animator?.fractionComplete = progress
  }
  
  func updateAppearance(forCommitProgress progress: CGFloat, touchLocation: CGPoint) {
    guard let ratingStackView = ratingStackView else { return }
    for subview in ratingStackView.arrangedSubviews {
      let translatedPoint = convert(touchLocation, to: subview)
      if subview.point(inside: translatedPoint, with: .none) {
        subview.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).withAlphaComponent(0.6)
      } else {
        subview.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).withAlphaComponent(0.2)
      }
    }
  }
  
  func completeCommit(at touchLocation: CGPoint) -> String {
    var selectedRating = ""
    
    guard let ratingStackView = ratingStackView else {
      return selectedRating
    }
    
    for subview in ratingStackView.arrangedSubviews where subview is UILabel {
      let subview = subview as! UILabel
      let translatedPoint = convert(touchLocation, to: subview)
      if subview.point(inside: translatedPoint, with: .none) {
        selectedRating = subview.text!
      }
    }

    endInteraction()
    
    return selectedRating
  }
  
  func beginPreview(forView view: UIView) {
    animator?.stopAnimation(false)
    blurView?.removeFromSuperview()

    prepareBlurView()

    overlaySnapshot?.removeFromSuperview()
    overlaySnapshot = view.snapshotView(afterScreenUpdates: false)
    if let overlaySnapshot = overlaySnapshot {
      blurView?.contentView.addSubview(overlaySnapshot)

      let adjustedCenter = view.superview?.convert(view.center, to: self)
      overlaySnapshot.center = adjustedCenter!
      prepareRatings(for: overlaySnapshot)
    }

    animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) {

      self.blurView?.effect = UIBlurEffect(style: .regular)

      self.overlaySnapshot?.layer.shadowRadius = 8
      self.overlaySnapshot?.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
      self.overlaySnapshot?.layer.shadowOpacity = 0.3

      self.ratingStackView?.alpha = 1
    }
    
    animator?.addCompletion { position in
      switch position {
      case .start:
        self.blurView?.removeFromSuperview()
      default:
        break
      }
    }
  }
  
  func endInteraction() {
    animator?.isReversed = true
    animator?.startAnimation()
  }
  
  private func prepareBlurView() {
    blurView = UIVisualEffectView(effect: .none)
    if let blurView = blurView {
      addSubview(blurView)
      blurView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        blurView.leftAnchor.constraint(equalTo: leftAnchor),
        blurView.rightAnchor.constraint(equalTo: rightAnchor),
        blurView.topAnchor.constraint(equalTo: topAnchor),
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
  }
  
  private func prepareRatings(for view: UIView) {
    let 👍label = UILabel()
    👍label.text = "👍"
    👍label.font = UIFont.systemFont(ofSize: 50)
    👍label.textAlignment = .center
    👍label.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).withAlphaComponent(0.2)
    let 👎label = UILabel()
    👎label.text = "👎"
    👎label.font = UIFont.systemFont(ofSize: 50)
    👎label.textAlignment = .center
    👎label.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).withAlphaComponent(0.2)
    
    ratingStackView = UIStackView(arrangedSubviews: [👍label, 👎label])
    if let ratingStackView = ratingStackView {
      ratingStackView.axis = .vertical
      ratingStackView.alignment = .fill
      ratingStackView.distribution = .fillEqually
      view.addSubview(ratingStackView)
      ratingStackView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        view.leftAnchor.constraint(equalTo: ratingStackView.leftAnchor),
        view.rightAnchor.constraint(equalTo: ratingStackView.rightAnchor),
        view.topAnchor.constraint(equalTo: ratingStackView.topAnchor),
        view.bottomAnchor.constraint(equalTo: ratingStackView.bottomAnchor)
        ])
      ratingStackView.alpha = 0
    }
  }
}
