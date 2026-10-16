import from uuid { uuid4 }
import from "@jac/mobui" { View, Text, Pressable, ScrollView, useWindowDimensions }
import from .theme { buildStyles }

node Venue {
    has name: str,
        neighborhood: str,
        category: str,
        rate: int,
        rating: str,
        walk: str,
        capacity: str,
        verified: bool = True;
}

node Reservation {
    has venue_name: str,
        neighborhood: str,
        hours: int,
        total: int,
        confirmation: str = str(uuid4());
}

def:pub load_venues() -> list[Venue] {
    venues = [root -->][?:Venue];
    if len(venues) == 0 {
        venues = [
            root ++> Venue(name="The Hoxton Lobby", neighborhood="Shoreditch", category="Boutique hotel", rate=2, rating="4.9", walk="3 min walk", capacity="8 bags"),
            root ++> Venue(name="Fern & Finch Café", neighborhood="Covent Garden", category="Neighborhood café", rate=2, rating="4.8", walk="5 min walk", capacity="5 bags"),
            root ++> Venue(name="The Hoxton Holborn", neighborhood="Bloomsbury", category="Boutique hotel", rate=3, rating="4.9", walk="8 min walk", capacity="12 bags"),
            root ++> Venue(name="Juniper House", neighborhood="Soho", category="Restaurant & bar", rate=2, rating="4.7", walk="9 min walk", capacity="6 bags")
        ];
    }
    return venues;
}

def:pub load_reservations() -> list[Reservation] { return [root -->][?:Reservation]; }

def:pub create_reservation(venue_name: str, neighborhood: str, hours: int) -> Reservation {
    safe_hours = hours if hours >= 1 and hours <= 12 else 3;
    rate = 3 if venue_name == "The Hoxton Holborn" else 2;
    return root ++> Reservation(venue_name=venue_name, neighborhood=neighborhood, hours=safe_hours, total=rate * safe_hours);
}

def:pub cancel_reservation(confirmation: str) -> bool {
    for reservation in [root -->][?:Reservation] {
        if reservation.confirmation == confirmation {
            del reservation;
            return True;
        }
    }
    return False;
}

glob styles = buildStyles();

def:pub app -> JsxElement {
    has venues: list[Venue] = [],
        reservations: list[Reservation] = [],
        destination: str = "London · Heathrow",
        hours: str = "3",
        cityMenu: bool = False;
    viewport = useWindowDimensions();

    async can with entry {
        venues = await load_venues();
        reservations = await load_reservations();
    }

    async def reserve(name: str, area: str) {
        count = 3;
        try { count = int(hours); } except ValueError { count = 3; }
        pending = Reservation(venue_name=name, neighborhood=area, hours=count, total=(3 if name == "The Hoxton Holborn" else 2) * count, confirmation="pending-" + name);
        reservations = reservations + [pending];
        created = await create_reservation(name, area, count);
        reservations = [created] + [r for r in reservations if r.confirmation != pending.confirmation];
    }

    async def cancel(ref: str) {
        _ = await cancel_reservation(ref);
        reservations = await load_reservations();
    }

    def choose(value: str) {
        destination = value;
    }

    activeReservations = reservations;
    activeValue = 0;
    for r in activeReservations { activeValue = activeValue + r.total; }

    return <ScrollView style={[styles.screen, {height: viewport.height}]} contentContainerStyle={styles.screenContent}>
        <View style={styles.nav}><View style={styles.brandMark}><Text style={styles.brandGlyph}>L</Text></View><Text style={styles.brandName}>luggagedrop</Text><View style={styles.navSpacer}/><Text style={styles.navLink}>Travel lighter</Text></View>
        <View>
            <View style={styles.hero}><View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>YOUR CITY, HANDS-FREE</Text></View><Text style={styles.heroTitle}>Drop your bags.{"\n"}Pick up your day.</Text><Text style={styles.heroSubtitle}>Safe, local luggage storage at places worth discovering.</Text></View>
            <View style={styles.searchPanel}><View style={styles.searchField}><Text style={styles.fieldLabel}>CITY OR AIRPORT</Text><Pressable style={styles.fieldValueRow} onPress={lambda { cityMenu = not cityMenu; }}><Text style={styles.durationValue}>{destination}</Text><Text style={styles.pin}>⌄</Text></Pressable></View><View style={styles.fieldDivider}/><View style={styles.durationField}><Text style={styles.fieldLabel}>HOURS</Text><View style={styles.durationRow}><Pressable style={styles.stepperButton} onPress={lambda { hours = str(int(hours) - 1 if int(hours) > 1 else 1); }}><Text style={styles.stepperText}>−</Text></Pressable><Text style={styles.durationValue}>{hours}</Text><Pressable style={styles.stepperButton} onPress={lambda { hours = str(int(hours) + 1 if int(hours) < 12 else 12); }}><Text style={styles.stepperText}>+</Text></Pressable></View></View></View>
            {cityMenu and <View style={styles.cityMenu}><Text style={styles.fieldLabel}>POPULAR DESTINATIONS</Text>{[<Pressable key={city} style={styles.cityOption} onPress={lambda { choose(city); cityMenu = False; }}><Text style={styles.cityOptionText}>{city}</Text></Pressable> for city in ["Atlanta, USA · ATL · Hartsfield-Jackson", "Los Angeles, USA · LAX · Los Angeles International", "New York City, USA · JFK · John F. Kennedy", "Chicago, USA · ORD · O’Hare", "Denver, USA · DEN · Denver International", "Dallas, USA · DFW · Dallas/Fort Worth", "Toronto, Canada · YYZ · Pearson", "Vancouver, Canada · YVR · Vancouver International", "Mexico City, Mexico · MEX · Mexico City International", "London, United Kingdom · LHR · Heathrow", "Paris, France · CDG · Charles de Gaulle", "Amsterdam, Netherlands · AMS · Schiphol", "Frankfurt, Germany · FRA · Frankfurt Airport", "Istanbul, Turkey · IST · Istanbul Airport", "Madrid, Spain · MAD · Adolfo Suárez Madrid–Barajas", "Rome, Italy · FCO · Fiumicino", "Zurich, Switzerland · ZRH · Zurich Airport", "Singapore · SIN · Changi", "Seoul, South Korea · ICN · Incheon", "Tokyo, Japan · HND · Haneda", "Tokyo, Japan · NRT · Narita", "Hong Kong · HKG · Hong Kong International", "Beijing, China · PEK · Capital / PKX · Daxing", "Shanghai, China · PVG · Pudong", "New Delhi, India · DEL · Indira Gandhi", "Bangkok, Thailand · BKK · Suvarnabhumi", "Sydney, Australia · SYD · Kingsford Smith", "Dubai, UAE · DXB · Dubai International", "Doha, Qatar · DOH · Hamad International", "Jeddah, Saudi Arabia · JED · King Abdulaziz", "Dammam, Saudi Arabia · DMM · King Fahd", "Abu Dhabi, UAE · AUH · Zayed International", "Johannesburg, South Africa · JNB · OR Tambo", "Cairo, Egypt · CAI · Cairo International", "Nairobi, Kenya · NBO · Jomo Kenyatta", "São Paulo, Brazil · GRU · Guarulhos", "Bogotá, Colombia · BOG · El Dorado"]]}</View>}
            <View style={styles.resultsHeader}><View><Text style={styles.sectionTitle}>Good spots nearby</Text><Text style={styles.resultSubtitle}>{destination}</Text></View><View style={styles.countPill}><Text style={styles.countText}>{str(len(venues))} spots</Text></View></View>
            {[<View key={r.confirmation} style={styles.bookingCard}><View style={styles.successCopy}><Text style={styles.successTitle}>{r.venue_name}</Text><Text style={styles.successSubtitle}>{str(r.hours)} hours · ${str(r.total)} · {"Saving reservation…" if r.confirmation[:8] == "pending-" else ("Ref " + r.confirmation[:8])}</Text></View><Pressable style={styles.cancelButton} onPress={lambda { cancel(r.confirmation); }}><Text style={styles.cancelText}>Cancel</Text></Pressable></View> for r in activeReservations]}
            <View style={styles.list}>{[<VenueCard key={v.name} venue={v} onReserve={reserve}/> for v in venues]}</View>
        </View>
    </ScrollView>;
}

def VenueCard(venue: Venue, onReserve: Callable[[str, str], None]) -> JsxElement {
    return <View style={styles.venueCard}><View style={styles.venueTop}><View style={styles.venueIcon}><Text style={styles.venueIconText}>{"H" if "hotel" in venue.category.lower() else "C"}</Text></View><View style={styles.venueInfo}><Text style={styles.venueName}>{venue.name}</Text><Text style={styles.mutedSmall}>{venue.neighborhood} · London</Text></View><View style={styles.rating}><Text style={styles.ratingText}>★ {venue.rating}</Text></View></View><View style={styles.venueMeta}><View style={styles.verifiedPill}><Text style={styles.verifiedText}>VERIFIED</Text></View><Text style={styles.mutedSmall}>{venue.walk} · {venue.capacity}</Text></View><View style={styles.cardFooter}><View><Text style={styles.price}><Text style={styles.priceValue}>${str(venue.rate)}</Text>/bag / hour</Text><Text style={styles.categoryText}>{venue.category}</Text></View><Pressable style={styles.reserveButton} onPress={lambda { onReserve(venue.name, venue.neighborhood); }}><Text style={styles.reserveButtonText}>Reserve</Text></Pressable></View></View>;
}
