//
//  SplitHide.swift
//  
//
//  Created by Steven Harris on 1/25/23.
//

import Foundation

/// An ObservableObject that `SplitView` observes to change whether  one of the `SplitSide`s is hidden.
///
/// Use the static `usingUserDefaults` method to save state automatically in `UserDefaults.standard`.
public class SplitHide: ObservableObject {
    @Published public var value: SplitSide? {
        didSet {
            setter?(value)
        }
    }
    public var getter: (()->SplitSide?)?
    public var setter: ((SplitSide?)->Void)?
    private var oldValue: SplitSide?
    
    public init(_ hide: SplitSide? = nil, getter: (()->SplitSide?)? = nil, setter: ((SplitSide?)->Void)? = nil) {
        let value = getter?() ?? hide
        self.value = value
        self.getter = getter
        self.setter = setter
        oldValue = value == nil ? .Secondary : nil
    }
    
    public func hide(_ side: SplitSide) {
        setValue(side)
    }
    
    public func toggle() {
        setValue(oldValue)
    }
    
    private func setValue(_ side: SplitSide?) {
        let newOldValue = value
        value = side
        oldValue = newOldValue
    }
    
    public static func usingUserDefaults(_ hide: SplitSide? = nil, key: String) -> SplitHide {
        SplitHide(
            hide,
            getter: {
                guard
                    let value = UserDefaults.standard.value(forKey: key) as? String,
                    let side = SplitSide(rawValue: value)
                else {
                    return nil
                }
                return side
            },
            setter: { side in
                UserDefaults.standard.set(side?.rawValue, forKey: key)
            }
        )
    }
}


