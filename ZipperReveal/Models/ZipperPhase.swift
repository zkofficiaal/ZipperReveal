//
//  ZipperPhase.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.
//  Defines the current phase of the zipper animation.
//

import Foundation

/// Represents the four visual phases of the zipper.
enum ZipperPhase {

    /// The zipper is completely closed.
    case closed

    /// The zipper is moving downward and opening.
    case opening

    /// The zipper is completely open.
    case opened

    /// The zipper is moving upward and closing.
    case closing
}
