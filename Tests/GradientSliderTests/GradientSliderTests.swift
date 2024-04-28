import XCTest
@testable import GradientSlider

final class GradientSliderTests: XCTestCase {
    
    private lazy var gSlider: [GradientSliderView] = {
        let slider: GradientSliderView = GradientSliderView()
        return slider
    }()
        
    func testExample() throws {
        debugPrint(gSlider)
    }
}
