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
        destination: str = "City · London",
        hours: str = "3",
        screen: str = "traveler";
    viewport = useWindowDimensions();

    async can with entry {
        venues = await load_venues();
        reservations = await load_reservations();
    }

    async def reserve(name: str, area: str) {
        count = 3;
        try { count = int(hours); } except ValueError { count = 3; }
        _ = await create_reservation(name, area, count);
        reservations = await load_reservations();
    }

    async def cancel(ref: str) {
        _ = await cancel_reservation(ref);
        reservations = await load_reservations();
    }

    def choose(value: str) { destination = value; }

    activeReservations = reservations;
    activeValue = 0;
    for r in activeReservations { activeValue = activeValue + r.total; }

    return <ScrollView style={[styles.screen, {height: viewport.height}]} contentContainerStyle={styles.screenContent}>
        <View style={styles.nav}><View style={styles.brandMark}><Text style={styles.brandGlyph}>L</Text></View><Text style={styles.brandName}>luggagedrop</Text><View style={styles.navSpacer}/><Pressable onPress={lambda { screen = "traveler"; }}><Text style={styles.navLink}>Find a spot</Text></Pressable><Pressable onPress={lambda { screen = "partner"; }}><Text style={styles.navLink}>For venues</Text></Pressable></View>
        {screen == "traveler" and <View>
            <View style={styles.modeRow}><Pressable style={styles.modeButton} onPress={lambda { choose("City · London"); }}><Text style={styles.modeText}>City</Text></Pressable><Pressable style={styles.modeButton} onPress={lambda { choose("Airport · Heathrow"); }}><Text style={styles.modeText}>Heathrow</Text></Pressable><Pressable style={styles.modeButton} onPress={lambda { choose("Airport · Schiphol"); }}><Text style={styles.modeText}>Schiphol</Text></Pressable></View>
            <View style={styles.hero}><View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>YOUR CITY, HANDS-FREE</Text></View><Text style={styles.heroTitle}>Drop your bags.{"\n"}Pick up your day.</Text><Text style={styles.heroSubtitle}>Safe, local luggage storage at places worth discovering.</Text></View>
            <View style={styles.destinationRow}><Pressable style={styles.destinationButton} onPress={lambda { choose("City · London"); }}><Text style={styles.destinationText}>London</Text></Pressable><Pressable style={styles.destinationButton} onPress={lambda { choose("City · Amsterdam"); }}><Text style={styles.destinationText}>Amsterdam</Text></Pressable></View>
            <View style={styles.searchPanel}><View style={styles.searchField}><Text style={styles.fieldLabel}>DESTINATION</Text><Text style={styles.durationValue}>{destination}</Text></View><View style={styles.fieldDivider}/><View style={styles.durationField}><Text style={styles.fieldLabel}>HOURS</Text><View style={styles.durationRow}><Pressable style={styles.stepperButton} onPress={lambda { hours = str(int(hours) - 1 if int(hours) > 1 else 1); }}><Text style={styles.stepperText}>−</Text></Pressable><Text style={styles.durationValue}>{hours}</Text><Pressable style={styles.stepperButton} onPress={lambda { hours = str(int(hours) + 1 if int(hours) < 12 else 12); }}><Text style={styles.stepperText}>+</Text></Pressable></View></View></View>
            <View style={styles.resultsHeader}><View><Text style={styles.sectionTitle}>Good spots nearby</Text><Text style={styles.resultSubtitle}>{destination}</Text></View><View style={styles.countPill}><Text style={styles.countText}>{str(len(venues))} spots</Text></View></View>
            {[<View key={r.confirmation} style={styles.bookingCard}><View style={styles.successCopy}><Text style={styles.successTitle}>{r.venue_name}</Text><Text style={styles.successSubtitle}>{str(r.hours)} hours · ${str(r.total)} · Ref {r.confirmation[:8]}</Text></View><Pressable style={styles.cancelButton} onPress={lambda { cancel(r.confirmation); }}><Text style={styles.cancelText}>Cancel</Text></Pressable></View> for r in activeReservations]}
            <View style={styles.list}>{[<VenueCard key={v.name} venue={v} onReserve={reserve}/> for v in venues]}</View>
        </View>}
        {screen == "partner" and <View><View style={styles.partnerHero}><View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>LUGGAGEDROP PARTNER</Text></View><Text style={styles.partnerTitle}>Your space earns.{"\n"}Travelers explore.</Text><Text style={styles.heroSubtitle}>A clear view of listings and booking activity.</Text></View><View style={styles.metricRow}><View style={styles.metricCard}><Text style={styles.metricValue}>{str(len(venues))}</Text><Text style={styles.metricLabel}>Listed venues</Text></View><View style={styles.metricCard}><Text style={styles.metricValue}>{str(len(activeReservations))}</Text><Text style={styles.metricLabel}>Bookings</Text></View><View style={styles.metricCard}><Text style={styles.metricValue}>${str(activeValue)}</Text><Text style={styles.metricLabel}>Booking value</Text></View></View><View style={styles.partnerSection}><Text style={styles.sectionTitle}>Venue activity</Text></View>{[<View key={v.name} style={styles.partnerVenue}><Text style={styles.venueName}>{v.name}</Text><Text style={styles.mutedSmall}>{v.neighborhood} · {v.category}</Text><Text style={styles.partnerRevenue}>{str(len([r for r in activeReservations if r.venue_name == v.name]))} active · ${str(v.rate)}/bag/hour</Text></View> for v in venues]}</View>}
    </ScrollView>;
}

def VenueCard(venue: Venue, onReserve: Callable[[str, str], None]) -> JsxElement {
    return <View style={styles.venueCard}><View style={styles.venueTop}><View style={styles.venueIcon}><Text style={styles.venueIconText}>{"H" if "hotel" in venue.category.lower() else "C"}</Text></View><View style={styles.venueInfo}><Text style={styles.venueName}>{venue.name}</Text><Text style={styles.mutedSmall}>{venue.neighborhood} · London</Text></View><View style={styles.rating}><Text style={styles.ratingText}>★ {venue.rating}</Text></View></View><View style={styles.venueMeta}><View style={styles.verifiedPill}><Text style={styles.verifiedText}>VERIFIED</Text></View><Text style={styles.mutedSmall}>{venue.walk} · {venue.capacity}</Text></View><View style={styles.cardFooter}><View><Text style={styles.price}><Text style={styles.priceValue}>${str(venue.rate)}</Text>/bag / hour</Text><Text style={styles.categoryText}>{venue.category}</Text></View><Pressable style={styles.reserveButton} onPress={lambda { onReserve(venue.name, venue.neighborhood); }}><Text style={styles.reserveButtonText}>Reserve</Text></Pressable></View></View>;
}
