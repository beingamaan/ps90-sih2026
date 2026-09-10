import os
import json
import base64
import requests
from io import BytesIO
from PIL import Image, ImageEnhance
from gtts import gTTS

# Load environment variables
from dotenv import load_dotenv
load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
REMOVE_BG_API_KEY = os.getenv("REMOVE_BG_API_KEY", "")

try:
    from rembg import remove as rembg_remove
    REMBG_AVAILABLE = True
except Exception as e:
    print(f"rembg import warning: {e}")
    REMBG_AVAILABLE = False

# ─── REAL AI BACKGROUND REMOVAL ───────────────────────
def remove_background(image_bytes: bytes) -> str:
    """
    1. Tries remove.bg API if valid API key is present.
    2. Uses local AI rembg model for 100% real offline background removal.
    3. Fallback to PIL studio matting.
    """
    # 1. Try Remove.bg API if valid key configured
    if REMOVE_BG_API_KEY and REMOVE_BG_API_KEY != "mock_key":
        try:
            response = requests.post(
                "https://api.remove.bg/v1.0/removebg",
                files={"image_file": image_bytes},
                data={"size": "auto"},
                headers={"X-Api-Key": REMOVE_BG_API_KEY},
                timeout=12
            )
            if response.status_code == 200:
                b64 = base64.b64encode(response.content).decode("utf-8")
                return f"data:image/png;base64,{b64}"
            else:
                print(f"Remove.bg API status {response.status_code}: {response.text}")
        except Exception as e:
            print(f"Remove.bg API exception: {e}")

    # 2. Real local AI background removal using rembg
    if REMBG_AVAILABLE:
        try:
            # Resize large photos to max 600px for ultra-fast 0.3s processing
            pil_img = Image.open(BytesIO(image_bytes)).convert("RGBA")
            pil_img.thumbnail((600, 600), Image.Resampling.LANCZOS)
            fast_buf = BytesIO()
            pil_img.save(fast_buf, format="PNG")
            fast_bytes = fast_buf.getvalue()

            output_bytes = rembg_remove(fast_bytes)
            b64 = base64.b64encode(output_bytes).decode("utf-8")
            return f"data:image/png;base64,{b64}"
        except Exception as e:
            print(f"rembg AI background removal error: {e}")

    # 3. Fallback PIL studio threshold matting
    try:
        image = Image.open(BytesIO(image_bytes)).convert("RGBA")
        datas = image.getdata()
        new_data = []
        # Replace high-brightness background pixels with clean white studio surface
        for item in datas:
            if item[0] > 220 and item[1] > 220 and item[2] > 220:
                new_data.append((255, 255, 255, 0))
            else:
                new_data.append(item)
        image.putdata(new_data)
        
        buffered = BytesIO()
        image.save(buffered, format="PNG")
        b64 = base64.b64encode(buffered.getvalue()).decode("utf-8")
        return f"data:image/png;base64,{b64}"
    except Exception as e:
        print(f"PIL fallback error: {e}")
        b64 = base64.b64encode(image_bytes).decode("utf-8")
        return f"data:image/png;base64,{b64}"


# ─── CRAFT KNOWLEDGE BASE FOR AUTHENTIC FALLBACKS ─────────
CRAFT_KNOWLEDGE_BASE = {
    "Textile": {
        "title_prefix": "Handwoven",
        "desc_template": "Masterfully handwoven using natural high-grade threads and traditional loom techniques. Features breathable texture, rich color vibrancy, and intricate ethnic patterns celebrating India's weaving heritage.",
        "regional": {
            "hi": "पारंपरिक करघे पर शुद्ध सूती एवं रेशमी धागों से निर्मित उत्कृष्ट वस्त्र। आरामदायक, प्राकृतिक रंगों से समृद्ध और कालातीत भारतीय कला का प्रतीक।",
            "bn": "ঐতিহ্যবাহী তাঁতে তৈরি চমৎকার ভারতীয় বস্ত্ৰকলা। নরম, আরামদায়ক এবং সমৃদ্ধ সংস্কৃতির প্রতীক।",
            "ta": "கைத்தறியில்பாரம்பரிய நெசவு முறைகளால் உருவாக்கப்பட்ட உயர்தர துணி. மென்மையானது மற்றும் பாரம்பரிய அழகு நிறைந்தது.",
            "te": "చేనేత మగ్గంపై సాంప్రదాయ దారాలతో నేసిన విశిష్టమైన వస్త్రము. నాణ్యమైనది మరియు సౌకర్యవంతమైనది.",
            "mr": "हाताने विणलेले पारंपरिक भारतीय वस्त्र. मऊ, आरामदायक आणि संस्कृतीचे सुंदर दर्शन घडवणारे.",
            "en": "Authentic handwoven textile crafted on traditional wooden looms with natural organic threads."
        },
        "story": "Woven on traditional wooden pit looms by 3rd-generation weaver families keeping ancient weaving arts alive."
    },
    "Pottery": {
        "title_prefix": "Terracotta Hand-Molded",
        "desc_template": "Hand-molded from pure natural clay and baked in traditional wood-fired kilns. Retains natural earthy aroma, eco-friendly durability, and timeless handcrafted aesthetics.",
        "regional": {
            "hi": "शुद्ध प्राकृतिक मिट्टी से निर्मित और पारंपरिक भट्टी में पकाया गया बर्तन। मिट्टी की सोंधी सुगंध, टिकाऊपन और पर्यावरण-अनुकूलता से परिपूर्ण।",
            "bn": "প্রাকৃতিক কাদা মাটি থেকে তৈরি এবং ঐতিহ্যবাহী ভাঁটিতে পোড়ানো কারুকাজ করা চমৎকার মৃৎশিল্প।",
            "ta": "இயற்கை களிமண்ணால் கைவினைஞர்களால் உருவாக்கப்பட்ட மண் பாண்டம். உறுதியானது மற்றும் சுற்றாடல் உகந்தது.",
            "te": "సహజమైన మట్టితో చేతితో తయారు చేసిన మట్టి పాత్ర. పర్యావరణ అనుకూలమైనది మరియు అందమైనది.",
            "mr": "नैसर्गिक मातीपासून बनवलेले व भट्टी भाजलेले सुंदर भांडे. पर्यावरणपूरक आणि आकर्षक.",
            "en": "Authentic terracotta clay craft molded by hand and wood-fired for rustic elegance."
        },
        "story": "Molded on traditional potter's wheels using riverbank clay and age-old wood firing methods."
    },
    "Woodwork": {
        "title_prefix": "Hand-Carved Wooden",
        "desc_template": "Hand-carved from seasoned natural solid wood with intricate rustic detailing. Polished with non-toxic organic oils for lasting natural sheen and strength.",
        "regional": {
            "hi": "ठोस प्राकृतिक लकड़ी पर बारीक नक्काशी से तैयार किया गया उत्पाद। टिकाऊ, प्राकृतिक फ़िनिश और कुशल शिल्पकारों की कला का अनूठा उदाहरण।",
            "bn": "প্রাকৃতিক কাঠে হাতে খোদাই করা চমৎকার কারুশিল্প। টেকসই এবং প্রাকৃতিক উজ্জ্বলতায় উজ্জ্বল।",
            "ta": "தரமான மரத்தில் கைகளால் செதுக்கப்பட்ட மரக் கலைப்பொருள். உறுதியானது மற்றும் இயற்கை மெருகூட்டல் கொண்டது.",
            "te": "నాణ్యమైన కలపపై చేతితో చెక్కబడిన కళాఖండము. మన్నికైనది మరియు సహజమైనది.",
            "mr": "भक्कम लाकडावर हाताने नक्षीकाम केलेले उत्पादन. टिकाऊ आणि नैसर्गिक सुंदर.",
            "en": "Sculpted from seasoned solid wood by traditional woodcarving artisans."
        },
        "story": "Hand-carved by hereditary woodworkers using classic chisels and ancestral carving motifs."
    },
    "Metalware": {
        "title_prefix": "Hand-Hammered Metal",
        "desc_template": "Sculpted and hand-hammered from pure brass and copper alloys. Treated for anti-tarnish durability while showcasing rich antique heritage lustre.",
        "regional": {
            "hi": "पीतल और तांबे पर हाथ की घड़ाई और नक्काशी से निर्मित पारंपरिक धातु शिल्प। अत्यंत टिकाऊ, चमकदार और शाही नक्काशी से सुसज्जित।",
            "bn": "পিতল ও তামায় হাতে পেটানো ঐতিহ্যবাহী ধাতুশিল্প। টেকসই এবং সময়হীন সংগ্রাহ্য বস্তু।",
            "ta": "பித்தளை மற்றும் செம்பில் கைகளால் செதுக்கப்பட்ட உலோகம். காலத்தால் அழியாத உறுதி கொண்டது.",
            "te": "ఇత్తడి మరియు రాగిపై చేతి పనితనంతో చేసిన సాంప్రదాయ లోహ హస్తకళ.",
            "mr": "पितळ आणि तांब्यावर हाताने घडवलेली पारंपरिक धातुकला. मजबूत आणि सुंदर.",
            "en": "Hand-hammered brass and copperware sculpted using traditional metalsmithing methods."
        },
        "story": "Hammered and engraved by master coppersmiths preserving centuries-old metal casting traditions."
    },
    "General": {
        "title_prefix": "Handcrafted Heritage",
        "desc_template": "Authentically handcrafted by skilled Indian artisans using eco-friendly sustainable materials. Blends traditional ethnic artistry with modern everyday utility.",
        "regional": {
            "hi": "पारंपरिक भारतीय कारीगरों द्वारा हस्तनिर्मित उत्कृष्ट शिल्प। टिकाऊ, कलात्मक और समृद्ध सांस्कृतिक पहचान से समृद्ध।",
            "bn": "ঐতিহ্যবাহী ভারতীয় কারিগরদের হাতে তৈরি অনন্য হস্তশিল্প।",
            "ta": "பாரம்பரிய இந்திய கைவினைஞர்களால் உருவாக்கப்பட்ட அசல் கைவினைப்பொருள்.",
            "te": "సాంప్రదాయ భారతీయ కళాకారుల చేతిలో రూపుదిద్దుకున్న హస్తకళ.",
            "mr": "भारतीय कारागिरांनी हाताने तयार केलेले अद्वितीय हस्तकला उत्पादन.",
            "en": "Authentic handmade craft created with heritage techniques and sustainable materials."
        },
        "story": "Handcrafted with passion and cultural pride by local artisan communities across rural India."
    }
}

# ─── GEMINI 3.6 FLASH CATALOGER ─────────────────────────
def generate_listing(transcript: str, category: str = "Textile", target_lang: str = "hi") -> dict:
    """
    Calls Gemini API to produce structured JSON listing with multi-language regional description.
    Falls back to smart dynamic template generation matching user description if API key is not present.
    """
    clean_transcript = transcript.strip() if transcript else ""
    if not clean_transcript:
        clean_transcript = f"{category} Craft"

    # Auto-detect craft category if transcript contains category indicators
    lower_t = clean_transcript.lower()
    detected_category = category
    if any(k in lower_t for k in ["clay", "terracotta", "matka", "pot", "vase", "bowl", "glazed", "kulhad", "ceramic"]):
        detected_category = "Pottery"
    elif any(k in lower_t for k in ["saree", "silk", "woven", "handloom", "dupatta", "cotton", "ikat", "chanderi", "zari", "cloth", "textile"]):
        detected_category = "Textile"
    elif any(k in lower_t for k in ["wood", "teak", "carved", "wooden", "spice box", "sculpture", "furniture"]):
        detected_category = "Woodwork"
    elif any(k in lower_t for k in ["brass", "copper", "metal", "bronze", "hammered", "bell", "utensil"]):
        detected_category = "Metalware"
    elif any(k in lower_t for k in ["jewelry", "necklace", "beads", "silver", "pendant", "bangle", "ring"]):
        detected_category = "Jewelry"

    kb = CRAFT_KNOWLEDGE_BASE.get(detected_category, CRAFT_KNOWLEDGE_BASE["General"])

    # Extract keywords for dynamic title & tags
    words = [w.strip(",.!?").title() for w in clean_transcript.split() if len(w) > 2]
    keywords = [w for w in words if w.lower() not in ["with", "from", "and", "the", "for", "made", "this", "that"]]
    
    unique_tags = list(dict.fromkeys(keywords + [detected_category, "Handmade", "Eco-Friendly"]))[:4]

    # Direct, un-embellished description matching the user's input strictly
    clean_sentence = clean_transcript.capitalize()
    if not clean_sentence.endswith("."):
        clean_sentence += "."
    
    fallback_desc = f"Handcrafted {clean_sentence}"
    
    # Regional text directly representing user description without exaggerated adjectives
    fallback_regional = clean_transcript

    # Product-specific Maker Story
    short_item = clean_transcript if len(clean_transcript) < 35 else clean_transcript[:32] + "..."
    dynamic_maker_story = f"Handcrafted by local artisans preserving traditional craftsmanship to create this {short_item}."

    # PS90 Feature Extraction Defaults
    material = "Natural Eco-Friendly Craft Material"
    if "silk" in lower_t: material = "Pure Handloom Silk"
    elif "cotton" in lower_t: material = "Organic Handloom Cotton"
    elif "clay" in lower_t or "terracotta" in lower_t: material = "Riverbank Terracotta Clay"
    elif "wood" in lower_t or "teak" in lower_t: material = "Seasoned Solid Wood"
    elif "brass" in lower_t: material = "Artisanal Brass"
    elif "copper" in lower_t: material = "Hand-Hammered Copper"

    color_motif = "Traditional Indian Art Motif"
    if "blue" in lower_t: color_motif = "Indigo Blue Accent & Engravings"
    elif "red" in lower_t: color_motif = "Crimson Red Border"
    elif "gold" in lower_t or "zari" in lower_t: color_motif = "Gold Zari Weave & Engravings"
    elif "floral" in lower_t: color_motif = "Hand-Carved Floral Motifs"

    origin = "Heritage Artisan Cluster, India"
    if "chanderi" in lower_t: origin = "Chanderi Craft Village, MP"
    elif "pochampally" in lower_t or "ikat" in lower_t: origin = "Pochampally Cluster, Telangana"
    elif "khurja" in lower_t: origin = "Khurja Pottery Center, UP"

    fallback_listing = {
        "title": clean_transcript.title()[:55],
        "description": fallback_desc,
        "regional_description": fallback_regional,
        "hindi_description": fallback_regional,
        "tags": unique_tags,
        "maker_story": dynamic_maker_story,
        "category": detected_category,
        "material": material,
        "color_motif": color_motif,
        "origin": origin,
        "status": "success"
    }

    if GEMINI_API_KEY and GEMINI_API_KEY != "mock_key":
        try:
            from google import genai
            client = genai.Client(api_key=GEMINI_API_KEY)
            prompt = f"""
            You are CraftBridge AI — an expert e-commerce cataloger assisting an artisan.
            Given the artisan's exact input description: "{clean_transcript}" (Category: {detected_category}, Target Regional Language: {target_lang}):

            CRITICAL REQUIREMENT: Do NOT add exaggerated adjectives or invented fluff (such as "masterfully handwoven", "intricate ethnic patterns", "royal heritage") unless the artisan explicitly mentioned them. Stay strictly faithful to what the artisan stated in "{clean_transcript}".

            Generate a valid JSON object with:
            - title: Clean e-commerce title based directly on "{clean_transcript}" (4-6 words).
            - description: Clear, accurate description in English directly expressing "{clean_transcript}" without adding fake or unmentioned details.
            - regional_description: Direct, accurate translation of "{clean_transcript}" in the target language code '{target_lang}' (e.g. Hindi in Devanagari script).
            - tags: Array of 4 relevant search tags directly related to "{clean_transcript}".
            - maker_story: Simple 2-sentence story about crafting this item ("{clean_transcript}").
            - category: Craft category (Textiles, Pottery, Woodwork, Metalware, Jewelry).
            - material: Extracted primary material (e.g. Pure Silk, Terracotta Clay).
            - color_motif: Extracted color/motif (e.g. Blue Floral).
            - origin: Craft cluster origin (e.g. Chanderi, MP).

            Return STRICTLY valid JSON without markdown codeblock formatting.
            """
            response = client.models.generate_content(
                model="gemini-3.6-flash",
                contents=prompt,
            )
            raw_text = response.text.strip()
            if raw_text.startswith("```json"):
                raw_text = raw_text[7:]
            if raw_text.startswith("```"):
                raw_text = raw_text[3:]
            if raw_text.endswith("```"):
                raw_text = raw_text[:-3]
            
            data = json.loads(raw_text.strip())
            reg = data.get("regional_description") or fallback_regional
            hindi = data.get("hindi_description") or reg
            return {
                "title": data.get("title", fallback_listing["title"]),
                "description": data.get("description", fallback_listing["description"]),
                "regional_description": reg,
                "hindi_description": hindi,
                "tags": data.get("tags", fallback_listing["tags"]),
                "maker_story": data.get("maker_story", dynamic_maker_story),
                "category": data.get("category", detected_category),
                "material": data.get("material", material),
                "color_motif": data.get("color_motif", color_motif),
                "origin": data.get("origin", origin),
                "status": "live_ai"
            }
        except Exception as e:
            print(f"Gemini API Error: {e}")

    return fallback_listing


# ─── DETERMINISTIC PRICING ENGINE ────────────────────────
MARKET_TABLE = {
    "Textile": (450, 950),
    "Pottery": (300, 750),
    "Jewelry": (500, 1200),
    "Woodcraft": (400, 1000),
    "Terracotta": (350, 800)
}

FESTIVAL_CALENDAR = {
    "Textile": "Diwali & Wedding Season demand is high! (+15% market value recommended)",
    "Pottery": "Dhanteras festival approach - clay crafts in peak buyer interest!",
    "Jewelry": "Festive festive season bonus active for handmade ornaments."
}

def calculate_price_suggestion(material_cost: float, hours_worked: float, category: str = "Textile") -> dict:
    fair_hourly_rate = 50.0
    overhead_buffer = 0.08
    
    labor_cost = hours_worked * fair_hourly_rate
    cost_floor = (material_cost + labor_cost) * (1.0 + overhead_buffer)
    
    market_min, market_max = MARKET_TABLE.get(category, (400, 800))
    base_recommendation = (market_min + market_max) / 2.0
    
    guardrail_triggered = cost_floor > base_recommendation
    recommended_price = cost_floor if guardrail_triggered else base_recommendation
    
    seasonal_note = FESTIVAL_CALENDAR.get(category, "High demand season for handmade Indian crafts!")
    
    return {
        "material_cost": round(material_cost, 2),
        "hours_worked": round(hours_worked, 1),
        "labor_cost": round(labor_cost, 2),
        "cost_floor": round(cost_floor, 2),
        "market_min": market_min,
        "market_max": market_max,
        "recommended_price": round(recommended_price, 2),
        "guardrail_triggered": guardrail_triggered,
        "guardrail_message": "Fair Wage Guardrail active: Guaranteed 100% cost recovery + fair artisan wage." if guardrail_triggered else "Fair market competitive pricing within traditional craft standards.",
        "seasonal_note": seasonal_note
    }


# ─── TEXT-TO-SPEECH MP3 AUDIO GENERATOR ─────────────────
def generate_tts_audio(text: str, lang: str = "hi") -> str:
    try:
        tts = gTTS(text=text, lang=lang, slow=False)
        fp = BytesIO()
        tts.write_to_fp(fp)
        b64 = base64.b64encode(fp.getvalue()).decode("utf-8")
        return f"data:audio/mp3;base64,{b64}"
    except Exception as e:
        print(f"TTS Audio Error: {e}")
        return ""
