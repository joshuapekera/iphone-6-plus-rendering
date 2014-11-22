//
//  PixelGridView.swift
//  PixelGridUIKit
//
//  Created by Ole Begemann on 23/09/14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

import UIKit

enum RenderingMode {
    case LogicalPixels
    case NativePixels
}

@objc protocol PixelGridViewDelegate: NSObjectProtocol {
    func pixelGridViewDidRedraw(view: PixelGridView)
}

@IBDesignable
class PixelGridView: UIView {

    @IBOutlet weak var delegate: PixelGridViewDelegate? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .Redraw
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    let lineColor = UIColor.greenColor()
    
    var renderingMode: RenderingMode = RenderingMode.LogicalPixels {
        didSet {
            setNeedsDisplay()
        }
    }

    var renderScaleFactor: CGFloat {
        if renderingMode == .NativePixels {
            return window?.screen.nativeScale ?? contentScaleFactor
        } else {
            return contentScaleFactor
        }
    }

    var lineWidth: CGFloat {
        return 1.0/renderScaleFactor
    }

    var pixelRect: CGRect {
        let pixelRect = CGRectApplyAffineTransform(self.bounds, upscaleTransform)
        return pixelRect
    }
    
    var upscaleTransform: CGAffineTransform {
        let scaleFactor = renderScaleFactor
        return CGAffineTransformMakeScale(scaleFactor, scaleFactor)
    }
    
    var downscaleTransform: CGAffineTransform {
        return CGAffineTransformInvert(upscaleTransform)
    }
    
    func renderToImage() -> UIImage {
        let path = pixelGridPath()
        path.lineWidth = 1.0

        UIGraphicsBeginImageContextWithOptions(pixelRect.size, true, 1.0)
        lineColor.setStroke()
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    func pixelGridPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        let lineOffset: CGFloat = 0.5
        
        var step: CGFloat = 2.0
        var i = 0
        
        var x = CGRectGetMinX(pixelRect)
        while x <= CGRectGetMaxX(pixelRect) {
            let lineCenterX = x + lineOffset
            let startPoint = CGPoint(x: lineCenterX, y: CGRectGetMinY(pixelRect))
            let endPoint = CGPoint(x: lineCenterX, y: CGRectGetMaxY(pixelRect))
            path.moveToPoint(startPoint)
            path.addLineToPoint(endPoint)
            
            ++i
            if (i % 30 == 0) {
                step *= 2
            }
            x += step
        }
        
        //        for x in stride(from: CGRectGetMinX(pixelRect), through: CGRectGetMaxX(pixelRect), by: 2) {
        //            let lineCenterX = x + 0.5
        //            let startPoint = CGPoint(x: lineCenterX, y: CGRectGetMinY(pixelRect))
        //            let endPoint = CGPoint(x: lineCenterX, y: CGRectGetMaxY(pixelRect))
        //            path.moveToPoint(startPoint)
        //            path.addLineToPoint(endPoint)
        //        }
        //
        //        for y in stride(from: CGRectGetMinY(pixelRect), through: CGRectGetMaxY(pixelRect), by: 2) {
        //            let lineCenterY = y + 0.5
        //            let startPoint = CGPoint(x: CGRectGetMinX(pixelRect), y: lineCenterY)
        //            let endPoint = CGPoint(x: CGRectGetMaxX(pixelRect), y: lineCenterY)
        //            path.moveToPoint(startPoint)
        //            path.addLineToPoint(endPoint)
        //        }
        
        return path
    }
    
    override func drawRect(rect: CGRect) {
        let path = pixelGridPath()
        
        path.lineWidth = lineWidth
        path.applyTransform(downscaleTransform)

        lineColor.setStroke()
        path.stroke()

        delegate?.pixelGridViewDidRedraw(self)
    }
}
