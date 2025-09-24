# Save-Your-Fridge

## Running Backend

```
cd backend
python3 -m venv venv

# Linux / macOS:
source venv/bin/activate
# On Windows (PowerShell):
venv\Scripts\activate

pip install -r requirements.txt

uvicorn app:app --reload --port 8000 --host 127.0.0.1
```
