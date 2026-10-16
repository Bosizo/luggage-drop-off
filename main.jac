import from "@jac/mobui" { View, Text, Pressable, TextInput, ScrollView, useWindowDimensions }
import from .theme { buildStyles }
import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

glob _cameraStream: any = None;
glob _scanTimer: any = None;

node Venue {
    has name: str,
        neighborhood: str,
        category: str,
        rate: int,
        rating: str,
        walk: str,
        capacity: str,
        city: str = "London",
        verified: bool = True,
        opening_hours: str = "07:00",
        closing_hours: str = "22:00",
        active_capacity: int = 8,
        partner_status: str = "Verified",
        owner_name: str = "",
        promotion: str = "";
}

node HostAccount {
    has email: str,
        name: str,
        created_at: str = "";
}

node Reservation {
    has venue_name: str,
        neighborhood: str,
        hours: int,
        total: int,
        bags: int = 1,
        confirmation: str = str(uuid4()),
        bag_tag: str = "",
        owner_code: str = "",
        host_code: str = "",
        checked_in: bool = False,
        released: bool = False,
        promotion: str = "",
        host_email: str = "";
}

"""Return only venues for the selected city; seed lightweight London inventory once."""
def:pub load_venues(destination: str = "London") -> list[Venue] {
    cityKey = destination.split(",")[0];
    allVenues = [root -->][?:Venue];
    if len(allVenues) == 0 and cityKey == "London" {
        root ++> Venue(name="The Hoxton Lobby", neighborhood="Shoreditch", category="Boutique hotel", rate=2, rating="4.9", walk="3 min walk", capacity="8 bags", city="London");
        root ++> Venue(name="Fern & Finch Café", neighborhood="Covent Garden", category="Neighborhood café", rate=2, rating="4.8", walk="5 min walk", capacity="5 bags", city="London");
        root ++> Venue(name="The Hoxton Holborn", neighborhood="Bloomsbury", category="Boutique hotel", rate=3, rating="4.9", walk="8 min walk", capacity="12 bags", city="London");
        root ++> Venue(name="Juniper House", neighborhood="Soho", category="Restaurant & bar", rate=2, rating="4.7", walk="9 min walk", capacity="6 bags", city="London");
        allVenues = [root -->][?:Venue];
    }
    return [v for v in allVenues if v.city == cityKey];
}

def load_reservations() -> list[Reservation] { return [root -->][?:Reservation]; }

def complete_host_signup(email: str, name: str) -> HostAccount {
    for account in [root -->][?:HostAccount] {
        if account.email == email { account.name = name; return account; }
    }
    return root ++> HostAccount(email=email, name=name);
}

def current_host() -> HostAccount | None {
    accounts = [root -->][?:HostAccount];
    if len(accounts) > 0 { return accounts[0]; }
    return None;
}

def my_host_venues() -> list[Venue] {
    accounts = [root -->][?:HostAccount];
    if len(accounts) == 0 { return []; }
    return [v for v in [root -->][?:Venue] if v.owner_name == accounts[0].email];
}

def my_handoffs() -> list[Reservation] {
    accounts = [root -->][?:HostAccount];
    if len(accounts) == 0 { return []; }
    return [r for r in [root -->][?:Reservation] if r.host_email == accounts[0].email];
}

def create_reservation(venue_name: str, neighborhood: str, hours: int, bags: int) -> Reservation {
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

def partner_signup(name: str, city: str, owner_name: str) -> Venue {
    if not name.strip() or not owner_name.strip() { raise ValueError("Venue and owner name are required"); }
    for venue in [root -->][?:Venue] {
        if venue.owner_name == owner_name and venue.name == name { return venue; }
    }
    return root ++> Venue(name=name.strip(), neighborhood="Airport district", category="Host partner", rate=2, rating="New", walk="Nearby", capacity="0 bags", city=city, verified=False, active_capacity=0, partner_status="Pending verification", owner_name=owner_name.strip());
}

def update_partner_venue(name: str, opening: str, closing: str, capacity: int, rate: int) -> bool {
    profiles = [root -->][?:HostAccount];
    if len(profiles) == 0 { return False; }
    for venue in [root -->][?:Venue] {
        if venue.name == name and venue.owner_name == profiles[0].email {
            venue.opening_hours = opening;
            venue.closing_hours = closing;
            venue.active_capacity = capacity if capacity >= 0 else 0;
            venue.rate = 3 if rate >= 3 else 2;
            return True;
        }
    }
    return False;
}

def create_handoff_reference(venue_name: str, neighborhood: str, hours: int, bags: int, promotion: str) -> Reservation {
    hostProfiles = [root -->][?:HostAccount];
    if len(hostProfiles) == 0 { raise ValueError("Host account required"); }
    hostVenue = None;
    for venue in [root -->][?:Venue] {
        if venue.name == venue_name and venue.owner_name == hostProfiles[0].email { hostVenue = venue; }
    }
    if hostVenue is None { raise ValueError("This host does not own that venue"); }
    safe_hours = hours if hours >= 1 and hours <= 12 else 3;
    safe_bags = bags if bags >= 1 else 1;
    rate = 3 if venue_name == "The Hoxton Holborn" else 2;
    tag = str(uuid4())[:8].upper();
    owner_pin = "";
    host_pin = "";
    for ch in tag { owner_pin = owner_pin + str((ord(ch) % 10)); host_pin = host_pin + str(((ord(ch) + 3) % 10)); }
    return root ++> Reservation(venue_name=venue_name, neighborhood=neighborhood, hours=safe_hours, total=rate * safe_hours * safe_bags, bags=safe_bags, bag_tag=tag, owner_code=owner_pin[:4], host_code=host_pin[:4], promotion=promotion, host_email=hostProfiles[0].email);
}

def release_bags(bag_tag: str, owner_code: str, host_code: str) -> bool {
    profiles = [root -->][?:HostAccount];
    if len(profiles) == 0 { return False; }
    for reservation in [root -->][?:Reservation] {
        if reservation.host_email == profiles[0].email and reservation.bag_tag == bag_tag and reservation.checked_in and reservation.owner_code == owner_code and reservation.host_code == host_code and not reservation.released {
            reservation.released = True;
            return True;
        }
    }
    return False;
}

def checkin_bags(bag_tag: str, owner_code: str) -> bool {
    profiles = [root -->][?:HostAccount];
    if len(profiles) == 0 { return False; }
    for userRoot in allroots() {
        for reservation in [userRoot -->][?:Reservation] {
            if reservation.host_email == profiles[0].email and reservation.bag_tag == bag_tag and not reservation.checked_in and not reservation.released {
                reservation.checked_in = True;
                return True;
            }
        }
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
    if "United States" in destination or "USA" in destination { return ["Credit or debit card", "PayPal", "Apple Pay", "Google Pay", "Cash App Pay"]; }
    if "Canada" in destination { return ["Credit or debit card", "PayPal", "Interac", "Apple Pay", "Google Pay"]; }
    if "United Kingdom" in destination { return ["Credit or debit card", "PayPal", "Apple Pay", "Google Pay", "Open banking"]; }
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
    if method == "Interac" { return "Popular bank payment in Canada"; }
    if method == "Carte Bancaire" { return "French domestic card network"; }
    if method == "Klarna" { return "Pay later or by bank in Germany"; }
    if method == "Open banking" { return "Pay directly from your UK bank"; }
    return "Digital wallet";
}

glob styles = buildStyles();

def:pub app -> JsxElement {
    has venues: list[Venue] = [],
        reservations: list[Reservation] = [],
        destination: str = "London, United Kingdom · LHR · Heathrow",
        hours: str = "3",
        bags: str = "1",
        airportSearch: str = "",
        hostEmail: str = "",
        hostPassword: str = "",
        hostName: str = "",
        authMessage: str = "",
        scannerStatus: str = "Camera QR scanning is not enabled in this web build. Use manual tag entry.",
        appMode: str = "traveler",
        checkoutDetails: dict[str, str] = {"screen": "browse", "cityMenu": "false", "payment": ""};
    viewport = useWindowDimensions();

    async can with entry {
        venues = await load_venues("London");
        if jacIsLoggedIn() { reservations = await load_reservations(); }
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

    async def onboardPartner {
        signup_result: dict | None = None;
        login_ok: bool = False;
        profile: HostAccount | None = None;
        venue: Venue | None = None;
        cityName = destination.split(",")[0];
        signup_result = await jacSignup(hostEmail, hostPassword);
        if not signup_result["success"] { authMessage = str(signup_result["error"]); return; }
        login_ok = await jacLogin(hostEmail, hostPassword);
        if not login_ok { authMessage = "Account created. Please sign in to continue."; return; }
        profile = await complete_host_signup(hostEmail, hostName);
        venue = await partner_signup(airportSearch, cityName, hostEmail);
        venues = [venue];
        reservations = await load_reservations();
        appMode = "partner";
        authMessage = "Host account created and signed in.";
    }

    async def signInHost {
        login_ok: bool = False;
        profile: HostAccount | None = None;
        login_ok = await jacLogin(hostEmail, hostPassword);
        if not login_ok { authMessage = "Could not sign in with those credentials."; return; }
        profile = await current_host();
        if profile is None { authMessage = "No host profile is linked to this account yet."; return; }
        authMessage = "Signed in as " + profile.name;
        appMode = "partner";
        venues = await load_venues(profile.email);
        reservations = await load_reservations();
    }

    def signOutHost {
        jacLogout();
        appMode = "traveler";
        authMessage = "";
    }

    async def saveVenueSettings(name: str, opening: str, closing: str, capacity: int, rate: int) {
        saved: bool = False;
        saved = await update_partner_venue(name, opening, closing, capacity, rate);
        authMessage = "Venue settings saved." if saved else "Venue update rejected: this account does not own that venue.";
    }

    async def issueBagTag(name: str, area: str) {
        created = await create_handoff_reference(name, area, int(hours), int(bags), "Show this screen for 15% off breakfast while your bags are stored");
        reservations = [created] + reservations;
        checkoutDetails = {"screen": "handoff", "venue": name, "area": area, "tag": created.bag_tag, "ownerCode": created.owner_code, "hostCode": created.host_code, "promo": created.promotion, "bags": str(created.bags)};
        appMode = "traveler";
    }

    async def markCheckedIn(tag: str, ownerPin: str) {
        checkinOk: bool = False;
        checkinOk = await checkin_bags(tag, ownerPin);
        authMessage = "Traveler code accepted; bag checked in." if checkinOk else "Check-in failed: tag or traveler code did not match this host.";
    }

    async def releaseBag(tag: str, ownerPin: str, hostPin: str) {
        releaseOk: bool = False;
        releaseOk = await release_bags(tag, ownerPin, hostPin);
        authMessage = "Both codes matched. Bag release recorded." if releaseOk else "Release denied: signed-in host, check-in, and both codes must match.";
    }

    def choose(value: str) {
        destination = value;
        airportSearch = "";
        checkoutDetails = {**checkoutDetails, "cityMenu": "false"};
        # Filter cached venues locally; no endpoint call on destination change.
        cityKey = value.split(",")[0];
        cachedCityVenues = [v for v in venues if v.city == cityKey];
        if len(cachedCityVenues) == 0 {
            venues = venues + [
                Venue(name=cityKey + " Airport Hotel", neighborhood="Airport district", category="Airport hotel", rate=3, rating="4.8", walk="5 min walk", capacity="10 bags", city=cityKey),
                Venue(name=cityKey + " Local Café", neighborhood="City center", category="Neighborhood café", rate=2, rating="4.7", walk="8 min walk", capacity="6 bags", city=cityKey)
            ];
        }
    }

    activeReservations = reservations;
    cityKey = destination.split(",")[0];
    matchedVenues = [v for v in venues if v.city == cityKey];
    nearbyVenues = matchedVenues;
    return <ScrollView style={[styles.screen, {height: viewport.height}]} contentContainerStyle={styles.screenContent}>
        <View style={styles.nav}><View style={styles.brandMark}><Text style={styles.brandGlyph}>L</Text></View><Text style={styles.brandName}>LuggageDrop</Text><View style={styles.navSpacer}/><Pressable onPress={lambda { appMode = "traveler"; }}><Text style={styles.navLink}>Travel</Text></Pressable><Pressable onPress={lambda { appMode = "partner"; }}><Text style={styles.navLink}>Host a space</Text></Pressable></View>
        {appMode == "partner" and <View>
            {not jacIsLoggedIn() and <View style={styles.partnerPanel}>
                <Text style={styles.sectionTitle}>Host partner account</Text>
                <Text style={styles.mutedSmall}>Create an account or sign in to manage your own host venue.</Text>
                <TextInput style={styles.partnerInput} value={hostName} placeholder="Host contact name" placeholderTextColor="#777c74" onChangeText={lambda (value: str) { hostName = value; }}/>
                <TextInput style={styles.partnerInput} value={hostEmail} placeholder="Email address" placeholderTextColor="#777c74" onChangeText={lambda (value: str) { hostEmail = value; }}/>
                <TextInput style={styles.partnerInput} value={hostPassword} placeholder="Password" placeholderTextColor="#777c74" secureTextEntry={True} onChangeText={lambda (value: str) { hostPassword = value; }}/>
                <TextInput style={styles.partnerInput} value={airportSearch} placeholder="Venue name" placeholderTextColor="#777c74" onChangeText={lambda (value: str) { airportSearch = value; }}/>
                <Pressable style={styles.checkoutButton} onPress={onboardPartner}><Text style={styles.reserveButtonText}>Create secure host account</Text></Pressable>
                <Pressable style={styles.backButton} onPress={lambda { signInHost(); }}><Text style={styles.backText}>Already registered? Sign in</Text></Pressable>
                <Text style={styles.mutedSmall}>{authMessage}</Text>
            </View>}
            {jacIsLoggedIn() and <View>
                <View style={styles.hero}><View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>LUGGAGEDROP HOSTS</Text></View><Text style={styles.heroTitle}>Welcome, local{"\n"}hosts.</Text><Text style={styles.heroSubtitle}>Offer secure bag storage and earn from unused space.</Text></View>
                <Pressable style={styles.backButton} onPress={lambda { signOutHost(); }}><Text style={styles.backText}>Sign out</Text></Pressable>
                {len([v for v in venues if v.owner_name == hostEmail]) == 0 and <View style={styles.partnerPanel}><Text style={styles.sectionTitle}>Add your venue</Text><Text style={styles.mutedSmall}>Your account is signed in. Create a host listing in your selected city.</Text><TextInput style={styles.partnerInput} value={airportSearch} placeholder="Venue name" placeholderTextColor="#777c74" onChangeText={lambda (value: str) { airportSearch = value; }}/><Pressable style={styles.checkoutButton} onPress={onboardPartner}><Text style={styles.reserveButtonText}>Create venue listing</Text></Pressable></View>}
                <View style={styles.partnerPanel}><Text style={styles.sectionTitle}>Your venue operations</Text><Text style={styles.mutedSmall}>Only venues owned by your signed-in account are shown. Verification remains pending until reviewed.</Text>
                    {[<View key={venue.name} style={styles.partnerVenue}><Text style={styles.venueName}>{venue.name}</Text><Text style={styles.mutedSmall}>{venue.city} · {venue.partner_status}</Text><Text style={styles.mutedSmall}>Open {venue.opening_hours}–{venue.closing_hours} · {str(venue.active_capacity)} bags · ${str(venue.rate)}/hour</Text><View style={styles.durationRow}><Pressable style={styles.stepperButton} onPress={lambda { saveVenueSettings(venue.name, venue.opening_hours, venue.closing_hours, venue.active_capacity + 1, venue.rate); }}><Text style={styles.stepperText}>+</Text></Pressable><Text style={styles.mutedSmall}>Capacity</Text><Pressable style={styles.stepperButton} onPress={lambda { saveVenueSettings(venue.name, venue.opening_hours, venue.closing_hours, venue.active_capacity, 3 if venue.rate == 2 else 2); }}><Text style={styles.stepperText}>$2 / $3</Text></Pressable></View></View> for venue in [v for v in venues if v.owner_name == hostEmail]]}</View>
                <View style={styles.partnerPanel}><Text style={styles.sectionTitle}>Bag release verification</Text><Text style={styles.mutedSmall}>{scannerStatus} Camera QR scanning requires a camera-enabled build. For now, enter the tag reference manually. Release is restricted to this account’s own venue and requires check-in plus both matching codes.</Text><TextInput style={styles.partnerInput} value={checkoutDetails["tagInput"] if "tagInput" in checkoutDetails else ""} placeholder="Bag tag reference" placeholderTextColor="#777c74" onChangeText={lambda (value: str) { checkoutDetails = {**checkoutDetails, "tagInput": value}; }}/><Pressable style={styles.backButton} onPress={lambda { markCheckedIn(checkoutDetails["tagInput"]); }}><Text style={styles.backText}>Check in tag</Text></Pressable><TextInput style={styles.partnerInput} value={checkoutDetails["ownerInput"] if "ownerInput" in checkoutDetails else ""} placeholder="Traveler owner code" placeholderTextColor="#777c74" onChangeText={lambda (value: str) { checkoutDetails = {**checkoutDetails, "ownerInput": value}; }}/><TextInput style={styles.partnerInput} value={checkoutDetails["hostInput"] if "hostInput" in checkoutDetails else ""} placeholder="Host release code" placeholderTextColor="#777c74" onChangeText={lambda (value: str) { checkoutDetails = {**checkoutDetails, "hostInput": value}; }}/><Pressable style={styles.checkoutButton} onPress={lambda { releaseBag(checkoutDetails["tagInput"], checkoutDetails["ownerInput"], checkoutDetails["hostInput"]); }}><Text style={styles.reserveButtonText}>Verify both codes and release</Text></Pressable></View>
            </View>}
        </View>}
        {appMode == "traveler" and checkoutDetails["screen"] == "checkout" and <View>
            <Pressable style={styles.backButton} onPress={lambda { checkoutDetails = {**checkoutDetails, "screen": "browse"}; }}><Text style={styles.backText}>Back to storage options</Text></Pressable>
            {checkoutDetails["confirmed"] == "true" and <View style={styles.checkoutSuccess}><Text style={styles.checkoutTitle}>Reservation confirmed</Text><Text style={styles.checkoutCopy}>{checkoutDetails["venue"]} · {checkoutDetails["bags"]} bags · {checkoutDetails["hours"]} hours</Text><Text style={styles.checkoutTotal}>${checkoutDetails["total"]}</Text><Text style={styles.checkoutCopy}>Demo checkout only. No payment was collected.</Text></View>}
            {not checkoutDetails["confirmed"] == "true" and <View>
                <View style={styles.hero}><View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>SECURE CHECKOUT</Text></View><Text style={styles.heroTitle}>Review your{"\n"}storage.</Text><Text style={styles.heroSubtitle}>Confirm your details and choose a payment method.</Text></View>
                <View style={styles.checkoutSummary}><Text style={styles.sectionTitle}>{checkoutDetails["venue"]}</Text><Text style={styles.checkoutCopy}>{checkoutDetails["area"]} · {destination}</Text><Text style={styles.checkoutCopy}>{checkoutDetails["bags"]} bags × {checkoutDetails["hours"]} hours</Text><Text style={styles.weightDisclaimer}>Each bag must weigh no more than 25 kg.</Text><View style={styles.checkoutRule}/><View style={styles.checkoutRow}><Text style={styles.checkoutCopy}>Total</Text><Text style={styles.checkoutTotal}>${checkoutDetails["total"]}</Text></View></View>
                <View style={styles.paymentSection}><Text style={styles.sectionTitle}>Choose payment</Text><Text style={styles.resultSubtitle}>Options vary by destination. Demo only; no payment details required.</Text></View>
                {[<Pressable key={method} style={styles.paymentOption} onPress={lambda { checkoutDetails = {**checkoutDetails, "payment": method}; }}><View style={styles.paymentRadio}><Text style={styles.paymentRadioText}>{"●" if checkoutDetails["payment"] == method else "○"}</Text></View><View><Text style={styles.paymentName}>{method}</Text><Text style={styles.mutedSmall}>{paymentDescription(method)}</Text></View></Pressable> for method in paymentMethods(destination)]}
                <Pressable style={styles.checkoutButton} onPress={confirmCheckout}><Text style={styles.reserveButtonText}>Confirm demo booking · ${checkoutDetails["total"]}</Text></Pressable>
            </View>}
        </View>}
        {appMode == "traveler" and checkoutDetails["screen"] == "browse" and <View>
            <View style={styles.hero}><View style={styles.eyebrow}><View style={styles.liveDot}/><Text style={styles.eyebrowText}>YOUR CITY, HANDS-FREE</Text></View><Text style={styles.heroTitle}>Drop your bags.{"\n"}Pick up your day.</Text><Text style={styles.heroSubtitle}>Safe, local luggage storage at places worth discovering.</Text></View>
            <View style={styles.searchPanel}><View style={styles.searchField}><Text style={styles.fieldLabel}>CITY OR AIRPORT</Text><Pressable style={styles.fieldValueRow} onPress={lambda { checkoutDetails = {**checkoutDetails, "cityMenu": "false" if checkoutDetails["cityMenu"] == "true" else "true"}; }}><Text style={styles.durationValue}>{destination}</Text><Text style={styles.pin}>⌄</Text></Pressable></View><View style={styles.fieldDivider}/><View style={styles.durationField}><Text style={styles.fieldLabel}>HOURS</Text><View style={styles.durationRow}><Pressable style={styles.stepperButton} onPress={lambda { hours = str(int(hours) - 1 if int(hours) > 1 else 1); }}><Text style={styles.stepperText}>−</Text></Pressable><Text style={styles.durationValue}>{hours}</Text><Pressable style={styles.stepperButton} onPress={lambda { hours = str(int(hours) + 1 if int(hours) < 12 else 12); }}><Text style={styles.stepperText}>+</Text></Pressable></View></View></View>
            <View style={styles.bagPanel}><View style={styles.bagInfo}><Text style={styles.fieldLabel}>NUMBER OF BAGS</Text><Text style={styles.mutedSmall}>No limit on number of bags</Text></View><View style={styles.durationRow}><Pressable style={styles.stepperButton} onPress={lambda { bags = str(int(bags) - 1 if int(bags) > 1 else 1); }}><Text style={styles.stepperText}>−</Text></Pressable><Text style={styles.durationValue}>{bags}</Text><Pressable style={styles.stepperButton} onPress={lambda { bags = str(int(bags) + 1); }}><Text style={styles.stepperText}>+</Text></Pressable></View></View>
            <Text style={styles.weightDisclaimer}>Maximum luggage weight: 25 kg per bag.</Text>
            {checkoutDetails["cityMenu"] == "true" and <View style={styles.cityMenu}><Text style={styles.fieldLabel}>AIRPORTS WORLDWIDE</Text><TextInput style={styles.airportSearch} value={airportSearch} placeholder="Search city, airport, or code" placeholderTextColor="#777c74" onChangeText={lambda (value: str) { airportSearch = value; }}/>{[<Pressable key={city} style={styles.cityOption} onPress={lambda { choose(city); }}><Text style={styles.cityOptionText}>{city}</Text></Pressable> for city in ["Abu Dhabi, UAE · AUH · Zayed International", "Amsterdam, Netherlands · AMS · Schiphol", "Anchorage, USA · ANC · Ted Stevens", "Atlanta, USA · ATL · Hartsfield-Jackson", "Austin, USA · AUS · Austin-Bergstrom", "Baltimore, USA · BWI · Thurgood Marshall", "Bangkok, Thailand · BKK · Suvarnabhumi", "Beijing, China · PEK · Capital / PKX · Daxing", "Bengaluru, India · BLR · Kempegowda", "Boston, USA · BOS · Logan", "Bogotá, Colombia · BOG · El Dorado", "Brisbane, Australia · BNE · Brisbane Airport", "Cairo, Egypt · CAI · Cairo International", "Calgary, Canada · YYC · Calgary International", "Cape Town, South Africa · CPT · Cape Town International", "Charlotte, USA · CLT · Charlotte Douglas", "Chicago, USA · ORD · O’Hare", "Cincinnati, USA · CVG · Cincinnati/Northern Kentucky", "Cleveland, USA · CLE · Cleveland Hopkins", "Colombo, Sri Lanka · CMB · Bandaranaike", "Columbus, USA · CMH · John Glenn", "Dallas, USA · DFW · Dallas/Fort Worth", "Dammam, Saudi Arabia · DMM · King Fahd", "Dar es Salaam, Tanzania · DAR · Julius Nyerere", "Denver, USA · DEN · Denver International", "Detroit, USA · DTW · Detroit Metro", "Doha, Qatar · DOH · Hamad International", "Dubai, UAE · DXB · Dubai International", "Edinburgh, United Kingdom · EDI · Edinburgh Airport", "Frankfurt, Germany · FRA · Frankfurt Airport", "Glasgow, United Kingdom · GLA · Glasgow Airport", "Guadalajara, Mexico · GDL · Miguel Hidalgo", "Hanoi, Vietnam · HAN · Noi Bai", "Ho Chi Minh City, Vietnam · SGN · Tan Son Nhat", "Honolulu, USA · HNL · Daniel K. Inouye", "Hong Kong · HKG · Hong Kong International", "Houston, USA · IAH · George Bush Intercontinental", "Hyderabad, India · HYD · Rajiv Gandhi", "Indianapolis, USA · IND · Indianapolis International", "Istanbul, Turkey · IST · Istanbul Airport", "Jakarta, Indonesia · CGK · Soekarno-Hatta", "Jeddah, Saudi Arabia · JED · King Abdulaziz", "Johannesburg, South Africa · JNB · OR Tambo", "Kampala, Uganda · EBB · Entebbe", "Kansas City, USA · MCI · Kansas City International", "Kuala Lumpur, Malaysia · KUL · Kuala Lumpur International", "Las Vegas, USA · LAS · Harry Reid", "Lima, Peru · LIM · Jorge Chávez", "Lisbon, Portugal · LIS · Humberto Delgado", "London, United Kingdom · LGW · Gatwick", "London, United Kingdom · LCY · London City", "London, United Kingdom · LHR · Heathrow", "London, United Kingdom · LTN · Luton", "London, United Kingdom · STN · Stansted", "Los Angeles, USA · LAX · Los Angeles International", "Madrid, Spain · MAD · Adolfo Suárez Madrid–Barajas", "Manila, Philippines · MNL · Ninoy Aquino", "Manchester, United Kingdom · MAN · Manchester Airport", "Melbourne, Australia · MEL · Melbourne Airport", "Miami, USA · MIA · Miami International", "Mexico City, Mexico · MEX · Mexico City International", "Minneapolis, USA · MSP · Minneapolis–Saint Paul", "Montreal, Canada · YUL · Montréal–Trudeau", "Muscat, Oman · MCT · Muscat International", "Nairobi, Kenya · NBO · Jomo Kenyatta", "Nashville, USA · BNA · Nashville International", "New Delhi, India · DEL · Indira Gandhi", "New Orleans, USA · MSY · Louis Armstrong", "New York City, USA · JFK · John F. Kennedy", "Orlando, USA · MCO · Orlando International", "Osaka, Japan · KIX · Kansai International", "Oslo, Norway · OSL · Oslo Airport", "Ottawa, Canada · YOW · Ottawa International", "Paris, France · CDG · Charles de Gaulle", "Perth, Australia · PER · Perth Airport", "Philadelphia, USA · PHL · Philadelphia International", "Phnom Penh, Cambodia · KTI · Techo International", "Phoenix, USA · PHX · Sky Harbor", "Pittsburgh, USA · PIT · Pittsburgh International", "Portland, USA · PDX · Portland International", "Prague, Czechia · PRG · Václav Havel", "Quito, Ecuador · UIO · Mariscal Sucre", "Raleigh, USA · RDU · Raleigh-Durham", "Reykjavík, Iceland · KEF · Keflavík", "Riyadh, Saudi Arabia · RUH · King Khalid", "Rome, Italy · FCO · Fiumicino", "Salt Lake City, USA · SLC · Salt Lake City International", "São Paulo, Brazil · GRU · Guarulhos", "San Diego, USA · SAN · San Diego International", "San Francisco, USA · SFO · San Francisco International", "San Jose, USA · SJC · San José Mineta", "Santiago, Chile · SCL · Arturo Merino Benítez", "Seoul, South Korea · ICN · Incheon", "Shanghai, China · PVG · Pudong", "Singapore · SIN · Changi", "Stockholm, Sweden · ARN · Arlanda", "Sydney, Australia · SYD · Kingsford Smith", "Taipei, Taiwan · TPE · Taoyuan International", "Tampa, USA · TPA · Tampa International", "Tokyo, Japan · HND · Haneda", "Tokyo, Japan · NRT · Narita", "Toronto, Canada · YYZ · Pearson", "Vancouver, Canada · YVR · Vancouver International", "Warsaw, Poland · WAW · Chopin Airport", "Washington, USA · IAD · Dulles", "Zurich, Switzerland · ZRH · Zurich Airport"] if airportSearch == "" or airportSearch.lower() in city.lower()]}</View>}
            <View style={styles.resultsHeader}><View><Text style={styles.sectionTitle}>Good spots nearby</Text><Text style={styles.resultSubtitle}>{destination}</Text></View><View style={styles.countPill}><Text style={styles.countText}>{str(len(nearbyVenues))} spots</Text></View></View>
            {[<View key={r.confirmation} style={styles.bookingCard}><View style={styles.successCopy}><Text style={styles.successTitle}>{r.venue_name}</Text><Text style={styles.successSubtitle}>{str(r.bags)} bags · {str(r.hours)} hours · ${str(r.total)} · Ref {r.confirmation[:8]}</Text><Pressable onPress={lambda { issueBagTag(r.venue_name, r.neighborhood); }}><Text style={styles.cityOptionText}>Create demo bag tag and check-in offer</Text></Pressable></View><Pressable style={styles.cancelButton} onPress={lambda { cancel(r.confirmation); }}><Text style={styles.cancelText}>Cancel</Text></Pressable></View> for r in activeReservations]}
            {("screen" in checkoutDetails and checkoutDetails["screen"] == "handoff") and <View style={styles.checkoutSummary}><Text style={styles.eyebrowText}>DEMO BAG HANDOFF</Text><Text style={styles.sectionTitle}>{checkoutDetails["venue"]}</Text><Text style={styles.checkoutCopy}>Digital tag reference</Text><Text style={styles.bagTag}>{checkoutDetails["tag"]}</Text><Text style={styles.checkoutCopy}>Show this tag to the host to receive a physical tag with the same reference.</Text><Text style={styles.promotionText}>{checkoutDetails["promo"]}</Text><Text style={styles.weightDisclaimer}>Both traveler and host demo codes must match for release. This reference is not a scannable QR or identity verification.</Text></View>}
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
