//
//  CopyWith.swift
//  RecipeAppUI
//
//  Created by Elyura on 19.07.26.
//

public protocol CopyWith {}

extension CopyWith {
    func copy(
        _ update: (inout Self) -> Void
    ) -> Self {
        var result = self
        update(&result)
        return result
    }
}
