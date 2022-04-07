//
//  BlogPost.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 07.04.2022.
//

import Foundation

struct BlogPost {
    let identifier: String
    let title: String
    let timestamp: TimeInterval
    let headerImageUrl: URL?
    let text: String
}
