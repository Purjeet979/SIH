from fastapi import FastAPI, UploadFile
import easyocr

reader = easyocr.Reader(['en', 'hi'])  # add more langs as needed

app = FastAPI()

@app.post("/ocr")
async def ocr(file: UploadFile):
    contents = await file.read()
    with open("temp.jpg", "wb") as f:
        f.write(contents)
    result = reader.readtext("temp.jpg")
    return {"text_blocks": [{"text": r[1], "confidence": r[2]} for r in result]}
