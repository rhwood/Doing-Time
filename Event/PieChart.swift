//
//  PieChart.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-11-21.
//
//  Copyright 2020 Randall Wood DBA Alexandria Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import SwiftUI

public struct PieChart: View {
    
    var slices: [PieChartSlice]
    
    public var body: some View {
        GeometryReader { geometry in
            self.makePieChart(geometry)
        }
    }
    
    func path(geometry: GeometryProxy, start: Float, end: Float) -> Path {
        let radius = geometry.size.width / 2
        let centerX = radius
        let centerY = radius
        var path = Path()
        path.move(to: CGPoint(x: centerX, y: centerY))
        path.addArc(center: CGPoint(x: centerX, y:centerY),
                    radius: radius,
                    startAngle: Angle(degrees: Double(start * 360) + 270),
                    endAngle: Angle(degrees: Double(end * 360) + 270),
                    clockwise: false)
        return path
    }
    
    func makePieChart(_ geometry: GeometryProxy) -> some View {
        return ZStack {
            ForEach(0..<slices.count, id: \.self) { index in
                path(geometry: geometry,
                     start: slices[index].start,
                     end: slices[index].end)
                    .fill(slices[index].color)
            }
        }
    }
}

public struct PieChartSlice {
    
    var start: Float
    var end: Float
    var color: Color
}

struct PieChart_Previews: PreviewProvider {
    static var slices = [
        PieChartSlice(start: 0, end: 0.65, color: .red),
        PieChartSlice(start: 0.70, end: 1, color: .green)
    ]
    static var previews: some View {
        PieChart(slices: slices)
    }
}
