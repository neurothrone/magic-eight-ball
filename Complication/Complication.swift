//
//  Complication.swift
//  Complication
//
//  Created by Zaid Neurothrone on 2022-10-12.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  let positiveAnswers: Set<String> = [
    "It is certain",
    "It is decidedly so",
    "Without a doubt",
    "Yes definitely",
    "As I see it, yes",
    "Most likely",
    "Outlook good",
    "Yes",
    "Signs point to yes"
  ]
  
  let uncertainAnswers: Set<String> = [
    "Reply hazy, try again",
    "Ask again later",
    "Better not tell you now",
    "Cannot predict now",
    "Concentrate and ask again"
  ]
  let negativeAnswers: Set<String> = [
    "Don't count on it", "My reply is no",
    "My sources say no",
    "Outlook not so good",
  "Very doubtful"
  ]
  
  var allAnswers: [String] = []
  
  init() {
    allAnswers.append(contentsOf: positiveAnswers)
    allAnswers.append(contentsOf: uncertainAnswers)
    allAnswers.append(contentsOf: positiveAnswers)
  }
  
  func prediction(for date: Date) -> PredictionEntry {
    let predictionNumber = Int(date.timeIntervalSince1970) % allAnswers.count
    let longPrediction = allAnswers[predictionNumber]
    
    let shortPrediction: String
    
    if positiveAnswers.contains(longPrediction) {
      shortPrediction = "😃"
    } else if uncertainAnswers.contains(longPrediction) {
      shortPrediction = "🤔"
    } else {
      shortPrediction = "☹️"
    }
    
    return PredictionEntry(
      date: date,
      longPrediction: longPrediction,
      shortPrediction: shortPrediction
    )
  }
  
  func placeholder(in context: Context) -> PredictionEntry {
    .example
  }
  
  func getSnapshot(in context: Context, completion: @escaping (PredictionEntry) -> ()) {
    let entry = prediction(for: .now)
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    var entries: [PredictionEntry] = []
    
    for i in 0..<60 {
      let predictionDate = Date.now + Double(i * 60)
      let entry = prediction(for: predictionDate)
      entries.append(entry)
    }
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct PredictionEntry: TimelineEntry {
  let date: Date
  let longPrediction: String
  let shortPrediction: String
  
  static let example: PredictionEntry = .init(date: .now, longPrediction: "It is certain", shortPrediction: "😃")
}

struct ComplicationEntryView : View {
  @Environment(\.widgetFamily) var widgetFamily
  
  var entry: Provider.Entry
  
  var body: some View {
    switch widgetFamily {
    case .accessoryRectangular, .accessoryInline:
      Text(entry.longPrediction)
    default:
      Text(entry.shortPrediction)
        .font(.system(size: 48))
        .minimumScaleFactor(0.1)
    }
  }
}

@main
struct Complication: Widget {
  let kind: String = "Complication"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      ComplicationEntryView(entry: entry)
    }
    .configurationDisplayName("Magic 8-Ball")
    .description("Predicts the future. Maybe.")
  }
}

struct Complication_Previews: PreviewProvider {
  static var previews: some View {
    ComplicationEntryView(entry: .example)
      .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
  }
}
