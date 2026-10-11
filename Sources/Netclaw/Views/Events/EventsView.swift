import SwiftUI

struct EventsView: View {
    @EnvironmentObject var appState: AppState
    @State private var filterCategory: EventCategory?
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            eventsToolbar
            Divider()
            eventsList
        }
        .navigationTitle("Events")
    }

    private var eventsToolbar: some View {
        HStack(spacing: 12) {
            Picker("Category", selection: $filterCategory) {
                Text("All").tag(nil as EventCategory?)
                ForEach(EventCategory.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.iconName).tag(cat as EventCategory?)
                }
            }
            .frame(width: 130)

            Spacer()

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search events...", text: $searchText)
                    .textFieldStyle(.plain)
                    .frame(width: 150)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))

            Text("\(filteredEvents.count) events")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    try? await appState.api?.clearEvents()
                    appState.events = []
                }
            } label: {
                Image(systemName: "trash")
            }
            .help("Clear events")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var filteredEvents: [BettercapEvent] {
        var events = appState.events
        if let cat = filterCategory {
            events = events.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            let s = searchText.lowercased()
            events = events.filter {
                ($0.tag?.lowercased().contains(s) ?? false) ||
                ($0.data?.description.lowercased().contains(s) ?? false)
            }
        }
        return events
    }

    private var eventsList: some View {
        Group {
            if filteredEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("No events")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredEvents) { event in
                            EventRow(event: event)
                        }
                    }
                    .padding(12)
                }
            }
        }
    }
}
