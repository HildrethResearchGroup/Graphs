//
//  Rating.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/23/25.
//  Copyright © 2025 Connor Barnes. All rights reserved.
//

import SwiftUI

// https://www.hackingwithswift.com/books/ios-swiftui/adding-a-custom-star-rating-component

struct Rating: View {
    var ratingState: RatingState
    
    var showEmptyStars = true
    
    @Binding var rating: Int
    
    init(ratingState: RatingState, rating: Binding<Int>, showEmptyStars: Bool = true) {
        self.ratingState = ratingState
        self._rating = rating
        self.showEmptyStars = showEmptyStars
    }
    
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { number in
                Button {
                    rating = number
                } label: {
                    image(for: number)
                        .foregroundStyle(number > rating ? offColor : onColor)
                }
                .buttonStyle(.borderless)
            }
            .disabled(isDisabled)
        }
        .rotationEffect(.degrees(180.0))
    }
    
    @ViewBuilder
    private func image(for number: Int) -> some View {
        if number > rating {
            offImage
        } else {
            onImage
        }
    }
    
    
    
    private var offImage = Image(systemName: "star")
    private var onImage =  Image(systemName: "star.fill")
    private var offColor: Color {
        if showEmptyStars {
            Color.gray
        } else {
            Color.clear
        }
    }
    private var onColor =  Color.gray
    
    
    var isDisabled: Bool {
        switch ratingState {
        case .none: return true
        case .single(_): return false
        case .unambiguousMultiple(_): return false
        case .ambiguousMultiple: return true
        }
    }
}


// MARK: - Preview
#Preview {
    Rating(ratingState: .single(3), rating: .constant(3))
}
