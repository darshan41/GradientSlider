//
//  GradientSliderView.swift
//  UIkitSlider
//
//  Created by Darshan S on 28/04/24.
//

#if canImport(UIKit)
import UIKit

@IBDesignable
open class GradientSliderView: UISlider {
    
    @IBInspectable public var thickness: CGFloat = 20 {
        didSet {
            update()
        }
    }
    
    @IBInspectable public var sliderThumbImage: UIImage? {
        didSet {
            update()
        }
    }
    
    open var minTrackColors: [UIColor] = [
        UIColor(red: 0.01, green: 0.95, blue: 0.56, alpha: 1.00),
        UIColor(red: 0.07, green: 0.85, blue: 0.75, alpha: 1.00)
    ] {
        didSet {
            update()
        }
    }
    
    @IBInspectable public var innerCircleColor: UIColor? = .white {
        didSet {
            update()
        }
    }
    
    @IBInspectable public var outerCircleColor: UIColor? = UIColor(red: 0.07, green: 0.85, blue: 0.75, alpha: 1.00) {
        didSet {
            update()
        }
    }
    
    @IBInspectable public var innerRadiusMultiplier: CGFloat = 0.60 {
        didSet {
            update()
        }
    }
    
    public var usesDefaultThumb: Bool = false {
        didSet {
            update()
        }
    }

    open var maxTrackColors: [UIColor] = [
        UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00),
        UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00)
    ] {
        didSet {
            update()
        }
    }
    
    public var overridedTrackRect: CGRect {
        CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y,
            width: bounds.width,
            height: thickness
        )
    }
    
    open override func trackRect(forBounds bounds: CGRect) -> CGRect {
        overridedTrackRect
    }
    
    open override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        update()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        update()
    }
    
    /// Helper Customised Image Generation with two colors.
    /// - Parameters:
    ///   - rect: The Given Rect, extract's height from rect.
    ///   - innerCircleColor: The Inner Color of the Circle.
    ///   - outerCircleColor: The Outer Color of the Circle.
    ///   - innerCircleDiameterMultiplier: The Inner Diameter multiplier compared with outer ones of the circle/
    ///   - extraHeightMultiplierForTheGivenRect: The Extra Height added W.R.T the given height from rect.
    /// - Returns: The Image Generated for thumb
    public static func generateTwoCircledThumbImage(
        _ rect: CGRect,
        innerCircleColor: UIColor,
        outerCircleColor: UIColor,
        innerCircleDiameterMultiplier: CGFloat = 0.65,
        extraHeightMultiplierForTheGivenRect: CGFloat = 0.5
    ) -> UIImage? {
        let outerCircle = CAShapeLayer()
        let outerCircleRadius = (rect.size.height + (rect.size.height * extraHeightMultiplierForTheGivenRect)) * 0.5
        let outerRect = CGRect(x: 0, y: 0, width: outerCircleRadius * 2, height: outerCircleRadius * 2)
        outerCircle.fillColor = outerCircleColor.cgColor
        outerCircle.path = UIBezierPath(roundedRect: outerRect, cornerRadius: outerCircleRadius).cgPath
        outerCircle.position = CGPoint(x: 0, y: 0)
        let innerCircle = CAShapeLayer()
        let innerCircleRadius = (outerCircleRadius * innerCircleDiameterMultiplier)
        let innerRect = CGRect(x: 0, y: 0, width: innerCircleRadius * 2, height: innerCircleRadius * 2)
        innerCircle.fillColor = innerCircleColor.cgColor
        let innerCircleCornerRadius = innerCircleRadius
        innerCircle.path = UIBezierPath(roundedRect: innerRect, cornerRadius: innerCircleCornerRadius).cgPath
        innerCircle.position = CGPoint(x: outerRect.midX - innerCircleCornerRadius, y: outerRect.midY - innerCircleCornerRadius)
        outerCircle.addSublayer(innerCircle)
        let layer = CALayer()
        layer.frame = outerRect
        layer.addSublayer(outerCircle)
        UIGraphicsBeginImageContextWithOptions(outerRect.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: Helper func's

private extension GradientSliderView {
    
    func updateThumbImage() {
        if sliderThumbImage == nil, !usesDefaultThumb {
            if let image = GradientSliderView.generateTwoCircledThumbImage(
                overridedTrackRect,
                innerCircleColor: innerCircleColor ?? .red,
                outerCircleColor: outerCircleColor ?? .green,
                innerCircleDiameterMultiplier: innerRadiusMultiplier,
                extraHeightMultiplierForTheGivenRect: 0.4
            ) {
                setThumbImage(image, for: .normal)
            }
        } else {
            setThumbImage(sliderThumbImage, for: .normal)
        }
    }
    
    func gradientImage(size: CGSize, colorSet: [CGColor]) throws -> UIImage? {
        let tgl = CAGradientLayer()
        tgl.frame = CGRect.init(x:0, y:0, width:size.width, height: size.height)
        tgl.cornerRadius = tgl.frame.height / 2
        tgl.masksToBounds = false
        tgl.colors = colorSet
        tgl.startPoint = CGPoint.init(x:0.0, y:0.5)
        tgl.endPoint = CGPoint.init(x:1.0, y:0.5)
        UIGraphicsBeginImageContextWithOptions(size, tgl.isOpaque, 0.0);
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        tgl.render(in: context)
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func update() {
        do {
            self.setMinimumTrackImage(try self.gradientImage(
                size: self.trackRect(forBounds: self.bounds).size,
                colorSet: minTrackColors.map({ $0.cgColor })),
                                      for: .normal)
            self.setMaximumTrackImage(try self.gradientImage(
                size: self.trackRect(forBounds: self.bounds).size,
                colorSet: maxTrackColors.map({ $0.cgColor })),
                                      for: .normal)
            updateThumbImage()
        } catch {
            self.minimumTrackTintColor = .systemRed
            self.maximumTrackTintColor = .systemGreen
        }
    }
}

#endif
