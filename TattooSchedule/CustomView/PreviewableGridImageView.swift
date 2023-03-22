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
    let geometry: GeometryProxy
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15.0)
            .frame(
                width: (geometry.size.width) * 0.32,
                height: 150
            )
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: (geometry.size.width) * 0.32,
                        height: 150
                    )
                    .cornerRadius(10.0)
                    .allowsHitTesting(false)
            }
            .shadow(radius: 10)
    }
}
