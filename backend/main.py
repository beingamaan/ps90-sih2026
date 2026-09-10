from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import time

from database import init_db, get_all_products, save_product
from ai_services import remove_background, generate_listing, calculate_price_suggestion, generate_tts_audio

app = FastAPI(
    title="CraftBridge AI Backend",
    description="AI-Driven Market Linkage and Smart Cataloging API for Marginalized Artisans",
    version="2.0.0"
)

# Enable CORS for Flutter Web & Mobile requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize SQLite database on startup
@app.on_event("startup")
def startup_event():
    init_db()

# Pydantic Schemas
class ListingRequest(BaseModel):
    transcript: str
    category: Optional[str] = "Textile"

class PriceRequest(BaseModel):
    material_cost: float
    hours_worked: float
    category: Optional[str] = "Textile"

class PublishRequest(BaseModel):
    title: str
    description: str
    tags: List[str]
    maker_story: str
    cost_floor: float
    buyer_price: float
    category: str
    image_url: Optional[str] = ""
    marketplace: Optional[str] = "ONDC Network"

class TTSRequest(BaseModel):
    text: str
    lang: Optional[str] = "hi"


# ─── API ENDPOINTS ──────────────────────────────────────

@app.get("/")
def root():
    return {"status": "online", "message": "CraftBridge AI Backend Service Ready"}

@app.post("/enhance-image")
async def enhance_image(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        enhanced_b64 = remove_background(contents)
        return {"status": "success", "enhanced_image": enhanced_b64}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class ListingRequest(BaseModel):
    transcript: str
    category: Optional[str] = "Textile"
    target_lang: Optional[str] = "hi"

@app.post("/generate-listing")
def api_generate_listing(req: ListingRequest):
    result = generate_listing(req.transcript, req.category, req.target_lang or "hi")
    return result

@app.post("/price-suggestion")
def api_price_suggestion(req: PriceRequest):
    result = calculate_price_suggestion(req.material_cost, req.hours_worked, req.category)
    return result

@app.post("/mock-publish")
def mock_publish(req: PublishRequest):
    # Simulated 1.5 second publishing delay to ONDC / GeM Government network
    time.sleep(1.5)
    
    # Save to SQLite database
    product_dict = req.dict()
    product_dict["status"] = f"Published on {req.marketplace}"
    item_id = save_product(product_dict)
    
    return {
        "status": "success",
        "message": f"Successfully published to {req.marketplace}",
        "listing_id": f"ONDC-IND-{item_id:04d}",
        "item_id": item_id,
        "live_url": f"https://ondc.in/catalog/{item_id:04d}"
    }

@app.get("/items")
def list_items():
    products = get_all_products()
    return {"status": "success", "products": products}

@app.post("/tts")
def api_tts(req: TTSRequest):
    audio_b64 = generate_tts_audio(req.text, req.lang)
    return {"status": "success", "audio_b64": audio_b64}
