//
//  LoginViewAnimations.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 19/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import EasyAnimation
import Async

class LoginViewAnimations {
    
    private var buttonPositionDelta: (x: CGFloat, width: CGFloat)!
    private var logoPositionDeltaX: CGFloat!
    private var shouldAnimate = false
    
    enum FadeStyle: CGFloat {
        case FadeIn = 1
        case FadeOut = 0
    }
    
    func prepare() {
        shouldAnimate = true
    }
    
    func stop() {
        shouldAnimate = false
    }
    
    func animateCornerRadiusForthAndBack(view: UIView) {
        
        let endValue = CGRectGetHeight(view.frame ?? CGRectZero) * 0.5
        
        UIView.animateAndChainWithDuration(0.2, delay: 0, options: [], animations: {
            view.layer.cornerRadius = 4
        }, completion: nil).animateWithDuration(0.5, animations: {
            view.layer.cornerRadius = endValue
        })
    }
    
    func animateSpringShrinkingToBall(button: UIView, logo: UIView, completion: Void -> Void) {
        
        let dimension = CGRectGetHeight(button.frame ?? CGRectZero)
        let deltaX = CGRectGetMidX(button.superview!.bounds) - dimension * 0.5 - CGRectGetMinX(button.frame)
        
        buttonPositionDelta = (x: deltaX, width: CGRectGetWidth(button.frame))
        logoPositionDeltaX = CGRectGetMidX(logo.superview!.bounds) - CGRectGetMidX(logo.frame)
        
        UIView.animateWithDuration(1.5, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [.FillModeForwards], animations: {
            
            button.layer.position.x += deltaX
            button.layer.frame.size.width = dimension
            logo.layer.position.x += self.logoPositionDeltaX
            
        }, completion: { _ in
            completion()
        })
    }
    
    func animateSpringExtendingToButton(button: UIView, logo: UIView, completion: Void -> Void) {
        
        UIView.animateWithDuration(1.5, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [.FillModeForwards], animations: {
            
            button.layer.position.x -= self.buttonPositionDelta.x
            button.layer.frame.size.width = self.buttonPositionDelta.width
            logo.layer.position.x -= self.logoPositionDeltaX
            
        }, completion: { _ in
            completion()
        })
    }
    
    func rotationAnimation(views: [UIView], duration: NSTimeInterval, cycles: Double) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI * 2.0 * cycles * duration)
        rotationAnimation.duration = duration
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = 1.0;
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        views.forEach {
            $0.layer.addAnimation(rotationAnimation, forKey: nil)
        }
    }
    
    func moveAnimation(views: [UIView], duration: NSTimeInterval, fade: FadeStyle, transition: CGPoint, completion: (Void -> Void)? = nil) {
        
        UIView.animateWithDuration(duration, delay: 0, options: [.CurveEaseIn], animations: {
            views.forEach {
                let frame = CGRect(
                    x: CGRectGetMinX($0.frame) + transition.x,
                    y: CGRectGetMinY($0.frame) + transition.y,
                    width: CGRectGetWidth($0.frame),
                    height: CGRectGetHeight($0.frame)
                )
                
                $0.frame = frame
                $0.alpha = fade.rawValue
            }
        }, completion: { _ in
            completion?()
        })
    }
    
    func blinkAnimation(views: [UIView], duration: NSTimeInterval) {
        
        if !shouldAnimate {
            return
        }
        
        Async.main(after: duration) {
            self.blinkAnimation(views, duration: duration)
        }
        
        UIView.animateWithDuration(duration * 0.5, animations: {
            views.forEach { $0.alpha = 0.5 }
        }, completion: { _ in
            UIView.animateWithDuration(duration * 0.5) { views.forEach { $0.alpha = 1.0 } }
        })
    }
    
    func bounceAnimation(views: [UIView], duration: NSTimeInterval) {
        
        if !shouldAnimate {
            return
        }
        
        Async.main(after: duration) {
            self.bounceAnimation(views, duration: duration)
        }
        
        let translationY = CAKeyframeAnimation(keyPath: "transform.translation.y")
        translationY.values = [0, 100, 0]
        translationY.keyTimes = [0, 0.45, 1]
        translationY.timingFunction = CAMediaTimingFunction(controlPoints: 0.7, 0.2, 0.3, 0.8)
        translationY.duration = duration
        translationY.repeatCount = 1
        
        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.values = [1, 0.95, 1.1, 0.95, 1.0]
        scaleX.keyTimes = [0, 0.44, 0.48, 0.52, 1]
        scaleX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        scaleX.duration = duration
        scaleX.repeatCount = 1
        
        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.values = [1, 1.1, 0.9, 1.1, 1]
        scaleY.keyTimes = [0, 0.44, 0.48, 0.52, 1]
        scaleY.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        scaleY.duration = duration
        scaleY.repeatCount = 1
        
        views.forEach {
            $0.layer.addAnimation(scaleX, forKey: nil)
            $0.layer.addAnimation(scaleY, forKey: nil)
            $0.layer.addAnimation(translationY, forKey: nil)
        }
    }
}
