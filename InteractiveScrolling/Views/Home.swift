//
//  Home.swift
//  InteractiveScrolling
//
//  Created by Akbarshah Jumanazarov on 12/15/23.
//

import SwiftUI

struct Home: View {
    var safeArea: EdgeInsets
    @State private var selectedMonth: Date = .currentMonth
    
    var body: some View {
        ScrollView {
            CalendarView()

            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    ForEach(1...15, id: \.self) { _ in
                        CardView()
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
    
    @ViewBuilder func CardView() -> some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.blue.gradient)
            .frame(height: 70)
            .overlay(alignment: .leading) {
                HStack(spacing: 12) {
                    Circle()
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 100, height: 5)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 70, height: 5)
                    }
                }
                .padding()
                .foregroundStyle(.white.opacity(0.25))
            }
    }
    
    @ViewBuilder func CalendarView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(currentMonth)
                .font(.system(size: 35))
                .frame(maxHeight: .infinity, alignment: .bottom)
                .overlay(alignment: .topLeading) {
                    GeometryReader {
                        let size = $0.size
                        
                        Text(year)
                            .font(.system(size: 25))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: calendarTitleViewHeight)
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 15) {
                        Button {
                            monthUpdate(false)
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .containerShape(.rect)
                        
                        Button {
                            monthUpdate()
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .containerShape(.rect)
                    }
                    .foregroundStyle(.primary)
                }
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(Calendar.current.weekdaySymbols, id: \.self) {sybmol in
                        Text(sybmol.prefix(3))
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: weekLabelHeight, alignment: .bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), content: {
                    ForEach(selectedMonthDates) { day in
                        Text(day.shortSymbol)
                            .foregroundStyle(day.ignored ? .secondary : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .contentShape(.rect)
                    }
                    
                })
                .frame(height: calendaGridHeight)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
        .padding(.top, safeArea.top)
        .padding(.bottom, bottomPadding)
        .background(Color.red.gradient)
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: selectedMonth)
    }
    
    var currentMonth: String {
        return format("MMMM")
    }
    
    var year: String {
        return format("YYYY")
    }
    
    var selectedMonthDates: [Day] {
        return extractDates(selectedMonth)
    }
    
    var calendarTitleViewHeight: CGFloat {
        return 75.0
    }
    
    var weekLabelHeight: CGFloat {
        return 30.0
    }
    
    var horizontalPadding: CGFloat {
        return 15
    }
    
    var topPadding: CGFloat {
        return 15
    }
    
    var bottomPadding: CGFloat {
        return 5
    }
    
    var calendaGridHeight: CGFloat {
        return CGFloat(selectedMonthDates.count/7) * 50
    }
    
    func monthUpdate(_ increment: Bool = true) {
        let calendar = Calendar.current
        guard let month = calendar.date(byAdding: .month,
                                        value: increment ? 1 : -1,
                                        to: selectedMonth) else { return }
        selectedMonth = month
    }
}

#Preview {
    ContentView()
}

extension Date {
    static var currentMonth: Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(from: Calendar.current.dateComponents([.month], from: .now)) else {
            return .now
        }
        
        return currentMonth
    }
}

extension View {
    func extractDates(_ month: Date) -> [Day] {
        var days: [Day] = []
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        guard let range = calendar.range(of: .day, in: .month, for: month)?.compactMap({ value -> Date? in
            return calendar.date(byAdding: .day, value: value - 1, to: month)
        }) else {
            return days
        }
        
        let firstWeekDay = calendar.component(.weekday, from: range.first!)
        
        for index in Array(0..<firstWeekDay-1).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -index - 1, to: range.first!) else {
                return days
            }
            
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
            
        }
        
        range.forEach { date in
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date))
        }
        
        let lastWeekDay = 7 - calendar.component(.weekday, from: range.last!)
        
        if lastWeekDay > 0 {
            for index in Array(0..<lastWeekDay) {
                guard let date = calendar.date(byAdding: .day, value: index + 1, to: range.last!) else {
                    return days
                }
                
                let shortSymbol = formatter.string(from: date)
                days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
                
            }
        }
        
        return days
    }
}

struct Day: Identifiable {
    let id = UUID()
    var shortSymbol: String
    var date: Date
    
    var ignored: Bool = false
}
