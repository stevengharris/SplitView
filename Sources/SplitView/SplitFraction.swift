//
//  SplitFraction.swift
//  
//
//  Created by Steven Harris on 1/25/23.
//

import Foundation

/// An ObservableObject that `SplitView` observes to change what fraction of the width/height the `Splitter`
/// will be positioned at upon open.
///
/// Use the static `usingUserDefaults` method to save state automatically in `UserDefaults.standard`.
public class SplitFraction: ObservableObject {
    public var value: CGFloat {
        didSet {
            setter?(value)
        }
    }
    public var getter: (()->CGFloat)?
    public var setter: ((CGFloat)->Void)?
    
    public init(_ fraction: CGFloat? = nil, getter: (()->CGFloat)? = nil, setter: ((CGFloat)->Void)? = nil) {
        value = getter?() ?? fraction ?? 0.5
        self.getter = getter
        self.setter = setter
    }

    public static func usingUserDefaults(_ fraction: CGFloat? = nil, key: String) -> SplitFraction {
        SplitFraction(
            fraction,
            getter: { UserDefaults.standard.value(forKey: key) as? CGFloat ?? fraction ?? 0.5 },
            setter: { fraction in UserDefaults.standard.set(fraction, forKey: key) }
        )
    }
}

