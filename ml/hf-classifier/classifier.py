import torch
from transformers import AutoImageProcessor, AutoModelForImageClassification
from PIL import Image

# Initialize model and processor lazily to avoid reloading
_processor = None
_model = None

def get_model():
    global _processor, _model
    if _model is None:
        model_name = "Maverick98/EcommerceClassifier"
        # Load the processor and model directly for inference (no training logic)
        _processor = AutoImageProcessor.from_pretrained(model_name)
        _model = AutoModelForImageClassification.from_pretrained(model_name)
        _model.eval()  # Set to evaluation mode
    return _processor, _model

def classify_product(image_path):
    """
    Loads an image, gets predictions from the model, and returns the top 3 results.
    """
    processor, model = get_model()
    
    # Load image via Pillow
    image = Image.open(image_path).convert("RGB")
    
    # Preprocess the image
    inputs = processor(images=image, return_tensors="pt")
    
    # Run inference
    with torch.no_grad():
        outputs = model(**inputs)
        
    logits = outputs.logits
    # Convert logits to probabilities
    probs = torch.nn.functional.softmax(logits, dim=-1)[0]
    
    # Get top 3 predictions
    top_k = torch.topk(probs, 3)
    top_indices = top_k.indices.tolist()
    top_probs = top_k.values.tolist()
    
    results = []
    for idx, prob in zip(top_indices, top_probs):
        label = model.config.id2label[idx]
        results.append({
            "label": label,
            "confidence": prob
        })
        
    return results

def map_to_lmpc_category(predicted_label):
    """
    Maps the 434 model categories into LMPC bucket categories.
    Adjust the keyword lists as you discover more labels from the model.
    """
    label = predicted_label.lower()
    
    # Proposed mapping table based on typical e-commerce taxonomy
    mapping = {
        "packaged_food": ["food", "grocery", "snack", "beverage", "drink", "chocolate", "biscuit", "tea", "coffee", "spice", "oil", "rice", "flour"],
        "cosmetics_toiletries": ["beauty", "cosmetic", "makeup", "skincare", "haircare", "soap", "shampoo", "perfume", "deodorant", "lotion", "cream", "wash", "paste"],
        "cement_construction": ["cement", "concrete", "brick", "tile", "plumbing", "hardware", "tool", "construction", "pipe"],
        "paints_varnishes": ["paint", "varnish", "primer", "thinner", "color", "enamel"],
        "textiles_garments": ["clothing", "apparel", "shirt", "jeans", "pant", "dress", "saree", "fabric", "textile", "footwear", "shoe"],
        "electricals_wire": ["electronic", "electrical", "wire", "cable", "switch", "bulb", "appliance", "mobile", "laptop", "battery", "led"],
        "lpg_cylinders": ["lpg", "cylinder", "gas"],
        "chemicals_liquids": ["chemical", "acid", "cleaner", "detergent", "phenyl", "liquid", "solvent", "fertilizer"]
    }
    
    for lmpc_category, keywords in mapping.items():
        if any(keyword in label for keyword in keywords):
            return lmpc_category
            
    return "other"

def run_pipeline(image_path, confidence_threshold=0.40):
    """
    End-to-end pipeline to test the mapping and uncertainty threshold.
    """
    print(f"Processing image: {image_path}")
    try:
        predictions = classify_product(image_path)
    except Exception as e:
        print(f"Error processing image: {e}")
        return
        
    top_pred = predictions[0]
    top_label = top_pred["label"]
    top_conf = top_pred["confidence"]
    
    print("\n--- Model Raw Output (Top 3) ---")
    for idx, pred in enumerate(predictions):
        print(f"{idx+1}. {pred['label']} (Confidence: {pred['confidence']:.2%})")
        
    print("\n--- LMPC Mapping Result ---")
    if top_conf < confidence_threshold:
        print(f"Result: uncertain (Confidence {top_conf:.2%} is below threshold {confidence_threshold:.2%})")
    else:
        lmpc_cat = map_to_lmpc_category(top_label)
        print(f"Mapped Category: {lmpc_cat}")

if __name__ == "__main__":
    # Test block
    import os
    test_image = "test_image.jpg"
    
    # Create a dummy image just so the script can run out of the box if no image is passed
    if not os.path.exists(test_image):
        print(f"Creating a dummy red {test_image} for testing...")
        img = Image.new('RGB', (224, 224), color = 'red')
        img.save(test_image)
        
    print("Testing the classifier pipeline...")
    # Change the threshold here if needed
    run_pipeline(test_image, confidence_threshold=0.40)
