import from uuid { uuid4 }
import from "@jac/mobui" {
    View,
    Text,
    Pressable,
    TextInput,
    ScrollView,
    useWindowDimensions
}
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

"""Load the curated, verified venue directory and seed it once."""
def:pub load_venues() -> list[Venue] {
    venues = [root -->][?:Venue];
    if len(venues) == 0 {
        venues = [
            root ++> Venue(name="The Hoxton Lobby", neighborhood="Shoreditch · London", category="Boutique hotel", rate=2, rating="4.9", walk="3 min walk", capacity="8 bags"),
            root ++> Venue(name="Fern & Finch Café", neighborhood="Covent Garden · London", category="Neighborhood café", rate=2, rating="4.8", walk="5 min walk", capacity="5 bags"),
            root ++> Venue(name="The Hoxton Holborn", neighborhood="Bloomsbury · London", category="Boutique hotel", rate=3, rating="4.9", walk="8 min walk", capacity="12 bags"),
            root ++> Venue(name="Juniper House", neighborhood="Soho · London", category="Restaurant & bar", rate=2, rating="4.7", walk="9 min walk", capacity="6 bags")
        ];
    }
    return venues;
}

"""Persist a traveler's reservation and return its graph-backed record."""
def:pub create_reservation(venue_name: str, neighborhood: str, hours: int) -> Reservation {
    safe_hours = hours if hours >= 1 and hours <= 12 else 3;
    rate = 2 if venue_name != "The Hoxton Holborn" else 3;
    total = rate * safe_hours;
    return root ++> Reservation(
        venue_name=venue_name,
        neighborhood=neighborhood,
        hours=safe_hours,
        total=total
    );
}

glob styles = buildStyles();

"""A compact verified venue listing with a clear per-hour price."""
def VenueCard(venue: Venue, onReserve: Callable[[str, str], None]) -> JsxElement {
    return <View style={styles.venueCard}>
        <View style={styles.venueTop}>
            <View style={styles.venueIcon}><Text style={styles.venueIconText}>{"H" if venue.category == "Boutique hotel" else ("C" if venue.category == "Neighborhood café" else "R")}</Text></View>
            <View style={styles.venueInfo}>
                <Text style={styles.venueName}>{venue.name}</Text>
                <Text style={styles.mutedSmall}>{venue.neighborhood}</Text>
            </View>
            <View style={styles.rating}><Text style={styles.ratingText}>★ {venue.rating}</Text></View>
        </View>
        <View style={styles.venueMeta}>
            <View style={styles.verifiedPill}><Text style={styles.verifiedText}>VERIFIED</Text></View>
            <Text style={styles.mutedSmall}>{venue.walk}  ·  {venue.capacity}</Text>
        </View>
        <View style={styles.cardFooter}>
            <View><Text style={styles.price}><Text style={styles.priceValue}>${str(venue.rate)}</Text>/bag / hour</Text><Text style={styles.categoryText}>{venue.category}</Text></View>
            <Pressable style={styles.reserveButton} onPress={lambda { onReserve(venue.name, venue.neighborhood); }}>
                <Text style={styles.reserveButtonText}>Reserve</Text>
            </Pressable>
        </View>
    </View>;
}

def:pub app -> JsxElement {
    has venues: list[Venue] = [],
        destination: str = "Shoreditch, London",
        hours: str = "3",
        booked: bool = False,
        selectedVenue: str = "",
        selectedArea: str = "",
        confirmation: str = "";

    viewport = useWindowDimensions();

    async can with entry {
        venues = await load_venues();
    }

    async def reserve(name: str, area: str) {
        if booked { return; }
        selectedVenue = name;
        selectedArea = area;
        parsed_hours = 3;
        try { parsed_hours = int(hours); } except ValueError { parsed_hours = 3; }
        reservation = await create_reservation(name, area, parsed_hours);
        confirmation = reservation.confirmation;
        booked = True;
    }

    def changeHours(delta: int) {
        current = 3;
        try { current = int(hours); } except ValueError { current = 3; }
        updated = current + delta;
        if updated < 1 { updated = 1; }
        if updated > 12 { updated = 12; }
        hours = str(updated);
    }

    return <ScrollView
        style={[styles.screen, {height: viewport.height}]}
        contentContainerStyle={styles.screenContent}
    >
        <View style={styles.nav}>
            <View style={styles.brandMark}><Text style={styles.brandGlyph}>L</Text></View>
            <Text style={styles.brandName}>luggagedrop</Text>
            <View style={styles.navSpacer}/>
            <Text style={styles.navLink}>How it works</Text>
            <View style={styles.avatar}><Text style={styles.avatarText}>J</Text></View>
        </View>

        <View style={styles.hero}>
            <View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>YOUR CITY, HANDS-FREE</Text></View>
            <Text style={styles.heroTitle}>Drop your bags.{"\n"}Pick up your day.</Text>
            <Text style={styles.heroSubtitle}>Safe, local luggage storage at places worth discovering.</Text>
        </View>

        <View style={styles.searchPanel}>
            <View style={styles.searchField}>
                <Text style={styles.fieldLabel}>NEAR</Text>
                <View style={styles.fieldValueRow}><Text style={styles.pin}>⌖</Text><TextInput style={styles.locationInput} value={destination} onChangeText={lambda (v: str) { destination = v; }} placeholder="City or neighborhood" placeholderTextColor="#777c74"/></View>
            </View>
            <View style={styles.fieldDivider}/>
            <View style={styles.durationField}>
                <Text style={styles.fieldLabel}>HOW LONG?</Text>
                <View style={styles.durationRow}>
                    <Pressable style={styles.stepperButton} onPress={lambda { changeHours(-1); }}><Text style={styles.stepperText}>−</Text></Pressable>
                    <Text style={styles.durationValue}>{hours} hours</Text>
                    <Pressable style={styles.stepperButton} onPress={lambda { changeHours(1); }}><Text style={styles.stepperText}>+</Text></Pressable>
                </View>
            </View>
        </View>

        <View style={styles.resultsHeader}>
            <View><Text style={styles.sectionTitle}>Good spots nearby</Text><Text style={styles.resultSubtitle}>A little local, a lot more freedom.</Text></View>
            <View style={styles.countPill}><Text style={styles.countText}>{str(len(venues))} spots</Text></View>
        </View>

        {booked and <View style={styles.successCard}>
            <View style={styles.successIcon}><Text style={styles.successCheck}>✓</Text></View>
            <View style={styles.successCopy}><Text style={styles.successTitle}>You’re all set</Text><Text style={styles.successSubtitle}>{selectedVenue} · {selectedArea}</Text><Text style={styles.successSubtitle}>{hours} hours held · Ref {confirmation[:8]}</Text></View>
            <Text style={styles.successTotal}>{"$" + str((int(hours) if hours.isdigit() else 3) * (3 if selectedVenue == "The Hoxton Holborn" else 2))}</Text>
        </View>}

        {(
            <View style={styles.emptyCard}><Text style={styles.emptyTitle}>Finding your local spots</Text><Text style={styles.mutedSmall}>Verified places will appear here.</Text></View>
        ) if len(venues) == 0 else <View style={styles.list}>
            {[<VenueCard key={v.name} venue={v} onReserve={reserve}/> for v in venues]}
        </View>}

        <View style={styles.trustLine}><Text style={styles.trustText}>SECURELY STORED  ·  INSURED  ·  FREE CANCELLATION</Text></View>
    </ScrollView>;
}
