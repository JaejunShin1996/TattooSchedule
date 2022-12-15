//
//  PreviewableGridImageView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 24/11/2022.
//

import Foundation
import SwiftUI

struct PreviewableGridImageView: View {
    let image: UIImage

    var body: some View {
        RoundedRectangle(cornerRadius: 15.0)
            .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15,
                   height: 150)
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: (UIScreen.main.bounds.width) * 0.33 - 15, height: 150)
                    .cornerRadius(10.0)
                    .allowsHitTesting(false)
            }
    }
}
