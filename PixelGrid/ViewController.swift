//
//  ViewController.swift
//  PixelGrid
//
//  Created by Ole Begemann on 23/09/14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

import UIKit
import Swift

class ViewController: UIViewController, PixelGridViewDelegate {

    @IBOutlet weak var pixelGridView: PixelGridView!
    @IBOutlet weak var scaleFactorLabel: UILabel!
    @IBOutlet weak var boundsLabel: UILabel!
    @IBOutlet weak var pixelRectLabel: UILabel!
    @IBOutlet weak var lineWidthLabel: UILabel!
    @IBOutlet weak var lineOffsetLabel: UILabel!
    @IBOutlet weak var lineOriginSlider: UISlider!
    @IBOutlet weak var lineWidthSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pixelGridView.delegate = self
        resetLineWidth(self)
        resetLineOffset(self)
        updateUI()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func selectRenderingMode(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: pixelGridView.renderingMode = .LogicalPixels
        case 1: pixelGridView.renderingMode = .NativePixels
        default: NSException(name: NSInternalInconsistencyException, reason: "Execution should never reach this point", userInfo: nil).raise()
        }
    }

    func updateUI() {
        self.scaleFactorLabel.text = "scaleFactor \(pixelGridView.renderScaleFactor)"
        self.boundsLabel.text = "bounds: \(pixelGridView.bounds)"
        self.pixelRectLabel.text = "pixelRect: \(pixelGridView.pixelRect)"
        self.lineWidthLabel.text = "lineWidth: \(pixelGridView.lineWidth)"
        self.lineOffsetLabel.text = "lineOffset: \(pixelGridView.lineOrigin)"
    }

    func pixelGridViewDidRedraw(view: PixelGridView) {
        updateUI()
    }
    
    @IBAction func resetLineWidth(sender: AnyObject) {
        let lineWidth = 1.0 / pixelGridView.renderScaleFactor
        pixelGridView.lineWidth = lineWidth
        lineWidthSlider.value = Float(lineWidth)
    }
    
    @IBAction func lineWidthSliderChanged(sender: AnyObject) {
        pixelGridView.lineWidth = CGFloat(lineWidthSlider.value)
    }
    
    @IBAction func resetLineOffset(sender: AnyObject) {
        let lineOrigin = 0.5
        pixelGridView.lineOrigin = CGFloat(lineOrigin)
        lineOriginSlider.value = Float(lineOrigin)
    }
    
    @IBAction func lineOriginSliderChanged(sender: AnyObject) {
        pixelGridView.lineOrigin = CGFloat(lineOriginSlider.value)
    }

    @IBAction func renderToImage(sender: AnyObject) {
        let image = pixelGridView.renderToImage()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

