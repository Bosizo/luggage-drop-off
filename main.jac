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
        city: str = "London",
        verified: bool = True;
}

node Reservation {
    has venue_name: str,
        neighborhood: str,
        hours: int,
        total: int,
        bags: int = 1,
        confirmation: str = str(uuid4());
}

def:pub load_venues(destination: str = "London") -> list[Venue] {
    venues = [root -->][?:Venue];
    if len(venues) == 0 {
        venues = [
            root ++> Venue(name="The Hoxton Lobby", neighborhood="Shoreditch", category="Boutique hotel", rate=2, rating="4.9", walk="3 min walk", capacity="8 bags"),
            root ++> Venue(name="Fern & Finch Café", neighborhood="Covent Garden", category="Neighborhood café", rate=2, rating="4.8", walk="5 min walk", capacity="5 bags"),
            root ++> Venue(name="The Hoxton Holborn", neighborhood="Bloomsbury", category="Boutique hotel", rate=3, rating="4.9", walk="8 min walk", capacity="12 bags"),
            root ++> Venue(name="Juniper House", neighborhood="Soho", category="Restaurant & bar", rate=2, rating="4.7", walk="9 min walk", capacity="6 bags"),
            root ++> Venue(name="Peachtree Grand Hotel", neighborhood="Downtown", category="Boutique hotel", rate=3, rating="4.8", walk="5 min walk", capacity="10 bags", city="Atlanta"),
            root ++> Venue(name="Westside Coffee House", neighborhood="Midtown", category="Neighborhood café", rate=2, rating="4.7", walk="6 min walk", capacity="6 bags", city="Atlanta"),
            root ++> Venue(name="Pacific Gateway Hotel", neighborhood="Westchester", category="Airport hotel", rate=3, rating="4.8", walk="7 min walk", capacity="12 bags", city="Los Angeles"),
            root ++> Venue(name="Queens Traveler Café", neighborhood="Jamaica", category="Neighborhood café", rate=2, rating="4.6", walk="4 min walk", capacity="5 bags", city="New York City"),
            root ++> Venue(name="The Loop House", neighborhood="The Loop", category="Boutique hotel", rate=3, rating="4.9", walk="5 min walk", capacity="9 bags", city="Chicago"),
            root ++> Venue(name="Mile High Stay", neighborhood="Central Park", category="Boutique hotel", rate=2, rating="4.7", walk="8 min walk", capacity="8 bags", city="Denver"),
            root ++> Venue(name="Trinity River Hotel", neighborhood="Downtown Dallas", category="Boutique hotel", rate=2, rating="4.7", walk="6 min walk", capacity="10 bags", city="Dallas"),
            root ++> Venue(name="Pearson Park Suites", neighborhood="Mississauga", category="Airport hotel", rate=3, rating="4.8", walk="5 min walk", capacity="12 bags", city="Toronto"),
            root ++> Venue(name="Harbour & Pine", neighborhood="Richmond", category="Neighborhood café", rate=2, rating="4.7", walk="7 min walk", capacity="5 bags", city="Vancouver"),
            root ++> Venue(name="Casa del Centro", neighborhood="Centro Histórico", category="Boutique hotel", rate=2, rating="4.8", walk="6 min walk", capacity="8 bags", city="Mexico City"),
            root ++> Venue(name="Left Bank Luggage Lounge", neighborhood="Le Marais", category="Boutique hotel", rate=3, rating="4.9", walk="4 min walk", capacity="10 bags", city="Paris"),
            root ++> Venue(name="Canal House Amsterdam", neighborhood="Centrum", category="Boutique hotel", rate=2, rating="4.8", walk="5 min walk", capacity="7 bags", city="Amsterdam"),
            root ++> Venue(name="Main River Coffee", neighborhood="Innenstadt", category="Neighborhood café", rate=2, rating="4.6", walk="6 min walk", capacity="6 bags", city="Frankfurt"),
            root ++> Venue(name="Bosphorus Corner Hotel", neighborhood="Arnavutköy", category="Boutique hotel", rate=3, rating="4.8", walk="8 min walk", capacity="9 bags", city="Istanbul"),
            root ++> Venue(name="Barajas Garden Stay", neighborhood="Barajas", category="Airport hotel", rate=2, rating="4.7", walk="5 min walk", capacity="10 bags", city="Madrid"),
            root ++> Venue(name="Roman Holiday House", neighborhood="Prati", category="Boutique hotel", rate=2, rating="4.9", walk="7 min walk", capacity="8 bags", city="Rome"),
            root ++> Venue(name="Zurich Central Café", neighborhood="Kloten", category="Neighborhood café", rate=2, rating="4.7", walk="4 min walk", capacity="5 bags", city="Zurich"),
            root ++> Venue(name="Changi Garden Hotel", neighborhood="Changi Village", category="Airport hotel", rate=3, rating="4.8", walk="6 min walk", capacity="12 bags", city="Singapore"),
            root ++> Venue(name="Seoul Station Stay", neighborhood="Jung-gu", category="Boutique hotel", rate=2, rating="4.8", walk="7 min walk", capacity="10 bags", city="Seoul"),
            root ++> Venue(name="Haneda House", neighborhood="Ota City", category="Airport hotel", rate=3, rating="4.9", walk="4 min walk", capacity="12 bags", city="Tokyo"),
            root ++> Venue(name="Kowloon Corner Café", neighborhood="Kowloon", category="Neighborhood café", rate=2, rating="4.7", walk="6 min walk", capacity="6 bags", city="Hong Kong"),
            root ++> Venue(name="Beijing Courtyard Hotel", neighborhood="Chaoyang", category="Boutique hotel", rate=3, rating="4.8", walk="8 min walk", capacity="10 bags", city="Beijing"),
            root ++> Venue(name="Pudong Pocket Inn", neighborhood="Pudong", category="Airport hotel", rate=3, rating="4.7", walk="5 min walk", capacity="12 bags", city="Shanghai"),
            root ++> Venue(name="Delhi Garden Café", neighborhood="Aerocity", category="Neighborhood café", rate=2, rating="4.6", walk="5 min walk", capacity="5 bags", city="New Delhi"),
            root ++> Venue(name="Bangkok Banyan House", neighborhood="Lat Krabang", category="Boutique hotel", rate=2, rating="4.8", walk="6 min walk", capacity="9 bags", city="Bangkok"),
            root ++> Venue(name="Sydney Harbour Stay", neighborhood="Mascot", category="Airport hotel", rate=3, rating="4.9", walk="5 min walk", capacity="11 bags", city="Sydney"),
            root ++> Venue(name="Dubai Palm Hotel", neighborhood="Al Garhoud", category="Boutique hotel", rate=3, rating="4.8", walk="5 min walk", capacity="12 bags", city="Dubai"),
            root ++> Venue(name="Doha Souq Suites", neighborhood="Al Wakrah", category="Boutique hotel", rate=3, rating="4.7", walk="8 min walk", capacity="9 bags", city="Doha"),
            root ++> Venue(name="Jeddah Corniche Café", neighborhood="Al Mohammadiyah", category="Neighborhood café", rate=2, rating="4.6", walk="7 min walk", capacity="6 bags", city="Jeddah"),
            root ++> Venue(name="Dammam Oasis Hotel", neighborhood="King Fahd Road", category="Boutique hotel", rate=2, rating="4.7", walk="8 min walk", capacity="8 bags", city="Dammam"),
            root ++> Venue(name="Abu Dhabi Garden Stay", neighborhood="Khalifa City", category="Airport hotel", rate=3, rating="4.8", walk="6 min walk", capacity="10 bags", city="Abu Dhabi"),
            root ++> Venue(name="Johannesburg Rosebank Hotel", neighborhood="Rosebank", category="Boutique hotel", rate=2, rating="4.7", walk="9 min walk", capacity="9 bags", city="Johannesburg"),
            root ++> Venue(name="Cairo Nile House", neighborhood="Heliopolis", category="Boutique hotel", rate=2, rating="4.6", walk="7 min walk", capacity="8 bags", city="Cairo"),
            root ++> Venue(name="Nairobi Acacia Lounge", neighborhood="Embakasi", category="Neighborhood café", rate=2, rating="4.6", walk="5 min walk", capacity="6 bags", city="Nairobi"),
            root ++> Venue(name="São Paulo Vila Hotel", neighborhood="Guarulhos", category="Airport hotel", rate=3, rating="4.8", walk="5 min walk", capacity="10 bags", city="São Paulo"),
            root ++> Venue(name="Bogotá El Dorado Stay", neighborhood="Fontibón", category="Boutique hotel", rate=2, rating="4.7", walk="7 min walk", capacity="9 bags", city="Bogotá")
        ];
    }
    cityKey = destination.split(",")[0];
    cityVenues = [v for v in venues if v.city == cityKey];
    if len(cityVenues) == 0 {
        venues = venues + [
            root ++> Venue(name=cityKey + " Airport Hotel", neighborhood="Airport district", category="Airport hotel", rate=3, rating="4.8", walk="5 min walk", capacity="10 bags", city=cityKey),
            root ++> Venue(name=cityKey + " Local Café", neighborhood="City center", category="Neighborhood café", rate=2, rating="4.7", walk="8 min walk", capacity="6 bags", city=cityKey)
        ];
    }
    return venues;
}

def:pub load_reservations() -> list[Reservation] { return [root -->][?:Reservation]; }

def:pub create_reservation(venue_name: str, neighborhood: str, hours: int, bags: int) -> Reservation {
    safe_hours = hours if hours >= 1 and hours <= 12 else 3;
    safe_bags = bags if bags >= 1 else 1;
    rate = 3 if venue_name == "The Hoxton Holborn" else 2;
    total = rate * safe_hours * safe_bags;
    return root ++> Reservation(venue_name=venue_name, neighborhood=neighborhood, hours=safe_hours, total=total, bags=safe_bags);
}

def:pub cancel_reservation(confirmation: str) -> bool {
    for reservation in [root -->][?:Reservation] {
        if reservation.confirmation == confirmation { del reservation; return True; }
    }
    return False;
}

def paymentMethods(destination: str) -> list[str] {
    if "Netherlands" in destination { return ["Credit or debit card", "PayPal", "Apple Pay", "Google Pay", "iDEAL"]; }
    if "India" in destination { return ["Credit or debit card", "PayPal", "UPI", "Apple Pay", "Google Pay"]; }
    if "China" in destination or "Hong Kong" in destination { return ["Credit or debit card", "Alipay", "WeChat Pay", "UnionPay"]; }
    if "Brazil" in destination { return ["Credit or debit card", "PayPal", "PIX", "Apple Pay", "Google Pay"]; }
    if "Singapore" in destination { return ["Credit or debit card", "PayPal", "PayNow", "Apple Pay", "Google Pay"]; }
    if "Japan" in destination or "Tokyo" in destination { return ["Credit or debit card", "PayPal", "PayPay", "Konbini", "Apple Pay"]; }
    if "United States" in destination or "USA" in destination { return ["Credit or debit card", "PayPal", "Apple Pay", "Google Pay", "Cash App Pay"];
    }
    if "Canada" in destination { return ["Credit or debit card", "PayPal", "Interac", "Apple Pay", "Google Pay"]; }
    if "United Kingdom" in destination { return ["Credit or debit card", "PayPal", "Apple Pay", "Google Pay", "Open banking"];
    }
    if "France" in destination { return ["Credit or debit card", "Carte Bancaire", "PayPal", "Apple Pay", "Google Pay"]; }
    if "Germany" in destination { return ["Credit or debit card", "PayPal", "Klarna", "Apple Pay", "Google Pay"]; }
    return ["Credit or debit card", "PayPal", "Apple Pay", "Google Pay", "Bank transfer"];
}

def paymentDescription(method: str) -> str {
    if method == "Credit or debit card" { return "Visa, Mastercard, or Amex"; }
    if method == "iDEAL" { return "Popular bank payment in the Netherlands"; }
    if method == "UPI" { return "Instant bank payment in India"; }
    if method == "Alipay" or method == "WeChat Pay" { return "Popular digital wallet in China"; }
    if method == "PIX" { return "Instant bank payment in Brazil"; }
    if method == "PayNow" { return "Instant bank transfer in Singapore"; }
    if method == "Konbini" { return "Convenience-store payment in Japan"; }
    if method == "Bank transfer" { return "Online banking payment"; }
    return "Digital wallet";
}

glob styles = buildStyles();

def:pub app -> JsxElement {
    has venues: list[Venue] = [],
        reservations: list[Reservation] = [],
        destination: str = "London, United Kingdom · LHR · Heathrow",
        hours: str = "3",
        bags: str = "1",
        checkoutDetails: dict[str, str] = {"screen": "browse", "cityMenu": "false", "payment": ""};
    viewport = useWindowDimensions();

    async can with entry {
        venues = await load_venues("London");
        reservations = await load_reservations();
    }

    def reserve(name: str, area: str, count: int, bagCount: int) {
        rate = 3 if name == "The Hoxton Holborn" else 2;
        checkoutDetails = {"screen": "checkout", "venue": name, "area": area, "bags": str(bagCount), "hours": str(count), "total": str(rate * count * bagCount), "payment": "", "confirmed": "false", "cityMenu": "false"};
    }

    def confirmCheckout {
        if checkoutDetails["payment"] { checkoutDetails = {**checkoutDetails, "confirmed": "true"}; }
    }

    async def cancel(ref: str) {
        _ = await cancel_reservation(ref);
        reservations = await load_reservations();
    }

    def choose(value: str) {
        destination = value;
        checkoutDetails = {**checkoutDetails, "cityMenu": "false"};
    }

    activeReservations = reservations;
    cityKey = destination.split(",")[0];
    matchedVenues = [v for v in venues if v.city == cityKey];
    nearbyVenues = matchedVenues if len(matchedVenues) > 0 else [
        Venue(name=cityKey + " Airport Hotel", neighborhood="Airport district", category="Airport hotel", rate=3, rating="4.8", walk="5 min walk", capacity="10 bags", city=cityKey),
        Venue(name=cityKey + " Local Café", neighborhood="City center", category="Neighborhood café", rate=2, rating="4.7", walk="8 min walk", capacity="6 bags", city=cityKey)
    ];
    return <ScrollView style={[styles.screen, {height: viewport.height}]} contentContainerStyle={styles.screenContent}>
        <View style={styles.nav}><View style={styles.brandMark}><Text style={styles.brandGlyph}>L</Text></View><Text style={styles.brandName}>LuggageDrop</Text><View style={styles.navSpacer}/><Text style={styles.navLink}>Travel lighter</Text></View>
        {checkoutDetails["screen"] == "checkout" and <View>
            <Pressable style={styles.backButton} onPress={lambda { checkoutDetails = {**checkoutDetails, "screen": "browse"}; }}><Text style={styles.backText}>Back to storage options</Text></Pressable>
            {checkoutDetails["confirmed"] == "true" and <View style={styles.checkoutSuccess}><Text style={styles.checkoutTitle}>Reservation confirmed</Text><Text style={styles.checkoutCopy}>{checkoutDetails["venue"]} · {str(checkoutDetails["bags"])} bags · {str(checkoutDetails["hours"])} hours</Text><Text style={styles.checkoutTotal}>${str(checkoutDetails["total"])}</Text><Text style={styles.checkoutCopy}>Demo checkout only. No payment was collected.</Text></View>}
            {not checkoutDetails["confirmed"] == "true" and <View>
                <View style={styles.hero}><View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>SECURE CHECKOUT</Text></View><Text style={styles.heroTitle}>Review your{"\n"}storage.</Text><Text style={styles.heroSubtitle}>Confirm your details and choose a payment method.</Text></View>
                <View style={styles.checkoutSummary}><Text style={styles.sectionTitle}>{checkoutDetails["venue"]}</Text><Text style={styles.checkoutCopy}>{checkoutDetails["area"]} · {destination}</Text><Text style={styles.checkoutCopy}>{str(checkoutDetails["bags"])} bags × {str(checkoutDetails["hours"])} hours</Text><Text style={styles.weightDisclaimer}>Each bag must weigh no more than 25 kg.</Text><View style={styles.checkoutRule}/><View style={styles.checkoutRow}><Text style={styles.checkoutCopy}>Total</Text><Text style={styles.checkoutTotal}>${str(checkoutDetails["total"])}</Text></View></View>
                <View style={styles.paymentSection}><Text style={styles.sectionTitle}>Choose payment</Text><Text style={styles.resultSubtitle}>Options vary by destination. Demo only; no payment details required.</Text></View>
                {[<Pressable key={method} style={styles.paymentOption} onPress={lambda { checkoutDetails = {**checkoutDetails, "payment": method}; }}><View style={styles.paymentRadio}><Text style={styles.paymentRadioText}>{"●" if checkoutDetails["payment"] == method else "○"}</Text></View><View><Text style={styles.paymentName}>{method}</Text><Text style={styles.mutedSmall}>{paymentDescription(method)}</Text></View></Pressable> for method in paymentMethods(destination)]}
                <Pressable style={styles.checkoutButton} onPress={confirmCheckout}><Text style={styles.reserveButtonText}>Confirm demo booking · ${str(checkoutDetails["total"])}</Text></Pressable>
            </View>}
        </View>}
        {checkoutDetails["screen"] == "browse" and <View>
            <View style={styles.hero}><View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>YOUR CITY, HANDS-FREE</Text></View><Text style={styles.heroTitle}>Drop your bags.{"\n"}Pick up your day.</Text><Text style={styles.heroSubtitle}>Safe, local luggage storage at places worth discovering.</Text></View>
            <View style={styles.searchPanel}><View style={styles.searchField}><Text style={styles.fieldLabel}>CITY OR AIRPORT</Text><Pressable style={styles.fieldValueRow} onPress={lambda { checkoutDetails = {**checkoutDetails, "cityMenu": "false" if checkoutDetails["cityMenu"] == "true" else "true"}; }}><Text style={styles.durationValue}>{destination}</Text><Text style={styles.pin}>⌄</Text></Pressable></View><View style={styles.fieldDivider}/><View style={styles.durationField}><Text style={styles.fieldLabel}>HOURS</Text><View style={styles.durationRow}><Pressable style={styles.stepperButton} onPress={lambda { hours = str(int(hours) - 1 if int(hours) > 1 else 1); }}><Text style={styles.stepperText}>−</Text></Pressable><Text style={styles.durationValue}>{hours}</Text><Pressable style={styles.stepperButton} onPress={lambda { hours = str(int(hours) + 1 if int(hours) < 12 else 12); }}><Text style={styles.stepperText}>+</Text></Pressable></View></View></View>
            <View style={styles.bagPanel}><View style={styles.bagInfo}><Text style={styles.fieldLabel}>NUMBER OF BAGS</Text><Text style={styles.mutedSmall}>No limit on number of bags</Text></View><View style={styles.durationRow}><Pressable style={styles.stepperButton} onPress={lambda { bags = str(int(bags) - 1 if int(bags) > 1 else 1); }}><Text style={styles.stepperText}>−</Text></Pressable><Text style={styles.durationValue}>{bags}</Text><Pressable style={styles.stepperButton} onPress={lambda { bags = str(int(bags) + 1); }}><Text style={styles.stepperText}>+</Text></Pressable></View></View>
            <Text style={styles.weightDisclaimer}>Maximum luggage weight: 25 kg per bag.</Text>
            {checkoutDetails["cityMenu"] == "true" and <View style={styles.cityMenu}><Text style={styles.fieldLabel}>INTERNATIONAL AIRPORT CITIES</Text>{[<Pressable key={city} style={styles.cityOption} onPress={lambda { choose(city); }}><Text style={styles.cityOptionText}>{city}</Text></Pressable> for city in ["Atlanta, USA · ATL · Hartsfield-Jackson", "Los Angeles, USA · LAX · Los Angeles International", "New York City, USA · JFK · John F. Kennedy", "Chicago, USA · ORD · O’Hare", "Denver, USA · DEN · Denver International", "Dallas, USA · DFW · Dallas/Fort Worth", "Toronto, Canada · YYZ · Pearson", "Vancouver, Canada · YVR · Vancouver International", "Mexico City, Mexico · MEX · Mexico City International", "London, United Kingdom · LHR · Heathrow", "Paris, France · CDG · Charles de Gaulle", "Amsterdam, Netherlands · AMS · Schiphol", "Frankfurt, Germany · FRA · Frankfurt Airport", "Istanbul, Turkey · IST · Istanbul Airport", "Madrid, Spain · MAD · Adolfo Suárez Madrid–Barajas", "Rome, Italy · FCO · Fiumicino", "Zurich, Switzerland · ZRH · Zurich Airport", "Singapore · SIN · Changi", "Seoul, South Korea · ICN · Incheon", "Tokyo, Japan · HND · Haneda", "Tokyo, Japan · NRT · Narita", "Hong Kong · HKG · Hong Kong International", "Beijing, China · PEK · Capital / PKX · Daxing", "Shanghai, China · PVG · Pudong", "New Delhi, India · DEL · Indira Gandhi", "Bangkok, Thailand · BKK · Suvarnabhumi", "Sydney, Australia · SYD · Kingsford Smith", "Dubai, UAE · DXB · Dubai International", "Doha, Qatar · DOH · Hamad International", "Jeddah, Saudi Arabia · JED · King Abdulaziz", "Dammam, Saudi Arabia · DMM · King Fahd", "Abu Dhabi, UAE · AUH · Zayed International", "Johannesburg, South Africa · JNB · OR Tambo", "Cairo, Egypt · CAI · Cairo International", "Nairobi, Kenya · NBO · Jomo Kenyatta", "São Paulo, Brazil · GRU · Guarulhos", "Bogotá, Colombia · BOG · El Dorado"]]}</View>}
            <View style={styles.resultsHeader}><View><Text style={styles.sectionTitle}>Good spots nearby</Text><Text style={styles.resultSubtitle}>{destination}</Text></View><View style={styles.countPill}><Text style={styles.countText}>{str(len(nearbyVenues))} spots</Text></View></View>
            {[<View key={r.confirmation} style={styles.bookingCard}><View style={styles.successCopy}><Text style={styles.successTitle}>{r.venue_name}</Text><Text style={styles.successSubtitle}>{str(r.bags)} bags · {str(r.hours)} hours · ${str(r.total)} · Ref {r.confirmation[:8]}</Text></View><Pressable style={styles.cancelButton} onPress={lambda { cancel(r.confirmation); }}><Text style={styles.cancelText}>Cancel</Text></Pressable></View> for r in activeReservations]}
            {len(matchedVenues) == 0 and <View style={styles.emptyCard}><Text style={styles.emptyTitle}>Preview spots in {cityKey}</Text><Text style={styles.mutedSmall}>Showing sample local venues while our verified network grows here.</Text></View>}
            <View style={styles.list}>{[<VenueCard key={v.name} venue={v} bags={int(bags)} hours={int(hours)} onReserve={reserve}/> for v in nearbyVenues]}</View>
            <Text style={styles.weightDisclaimer}>Luggage size and weight disclaimer: each bag must weigh no more than 25 kg.</Text>
        </View>}
    </ScrollView>;
}

def VenueCard(venue: Venue, bags: int, hours: int, onReserve: Callable[[str, str, int, int], None]) -> JsxElement {
    total = venue.rate * bags * hours;
    return <View style={styles.venueCard}><View style={styles.venueTop}><View style={styles.venueIcon}><Text style={styles.venueIconText}>{"H" if "hotel" in venue.category.lower() else "C"}</Text></View><View style={styles.venueInfo}><Text style={styles.venueName}>{venue.name}</Text><Text style={styles.mutedSmall}>{venue.neighborhood} · {venue.city}</Text></View><View style={styles.rating}><Text style={styles.ratingText}>★ {venue.rating}</Text></View></View><View style={styles.venueMeta}><View style={styles.verifiedPill}><Text style={styles.verifiedText}>VERIFIED</Text></View><Text style={styles.mutedSmall}>{venue.walk} · {venue.capacity}</Text></View><View style={styles.cardFooter}><View><Text style={styles.price}><Text style={styles.priceValue}>${str(venue.rate)}</Text>/bag / hour</Text><Text style={styles.categoryText}>{venue.category}</Text></View><View style={styles.reserveGroup}><Text style={styles.cardTotal}>Total ${str(total)}</Text><Pressable style={styles.reserveButton} onPress={lambda { onReserve(venue.name, venue.neighborhood, bags, hours); }}><Text style={styles.reserveButtonText}>Reserve</Text></Pressable></View></View></View>;
}
