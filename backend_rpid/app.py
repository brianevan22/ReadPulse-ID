from flask import Flask, request, jsonify
import numpy as np
import joblib
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # supaya bisa diakses dari Flutter Web (Chrome)

# Load model dan scaler
model = joblib.load('reading_interest_model.pkl')
scaler = joblib.load('reading_interest_scaler.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()

    # Ambil fitur dari JSON (HARUS sama nama key-nya dengan toJson() di Flutter)
    features = [
        data['frequency_per_week'],
        data['minutes_per_day'],
        data['enjoyment_scale'],
        data['has_personal_books'],
        data['format_preference'],
        data['genre_variety'],
        data['purpose'],
        data['reading_habit_duration']
    ]

    x = np.array(features, dtype='float32').reshape(1, -1)

    # Scaling sama seperti waktu training
    x_scaled = scaler.transform(x)

    # Probabilitas untuk tiap kelas
    probs = model.predict_proba(x_scaled)[0]  # [p0, p1, p2]
    label_idx = int(np.argmax(probs))
    labels = ['Rendah', 'Sedang', 'Tinggi']
    label = labels[label_idx]

    return jsonify({
        'level': label,
        'probs': probs.tolist(),
        'score': float(probs[label_idx])
    })

if __name__ == '__main__':
    app.run(debug=True, port=5000)
