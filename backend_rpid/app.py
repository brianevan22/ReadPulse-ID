from flask import Flask, request, jsonify
import numpy as np
import joblib
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Load model dan scaler (tidak digunakan untuk manual scoring, tetap dipertahankan)
model = joblib.load('reading_interest_model.pkl')
scaler = joblib.load('reading_interest_scaler.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()

    # Ambil nilai mentah sesuai UI (pastikan UI mengirim sesuai skema)
    q1 = int(data.get('frequency_per_week', 0))        # 0..4
    q2 = int(data.get('minutes_per_day', 0))          # 0..4
    q3 = int(data.get('enjoyment_scale', 0))         # 0..4 (API menerima 0..4)
    q4 = int(data.get('has_personal_books', 0))      # 0..1
    q5 = int(data.get('format_preference', 0))       # 0..3
    q6 = int(data.get('genre_variety', 0))           # 0..4
    q7 = int(data.get('purpose', 0))                 # 0..3
    q8 = int(data.get('reading_habit_duration', 0))  # 0..4
    q9 = int(data.get('discussion_habit', 0))        # 0..2 (UI has 3 options: 0,1,2)
    q10 = int(data.get('reading_community', 0))      # 0..3

    # Normalisasi tiap soal ke 0..1 menurut maks masing-masing
    s1 = (q1 / 4.0)           # soal 1 (0..4)
    s2 = (q2 / 4.0)           # soal 2 (0..4)
    s3 = (q3 / 4.0)           # soal 3 (0..4)
    s4 = (q4 / 1.0)           # soal 4 (0..1)
    s5 = (q5 / 3.0)           # soal 5 (0..3)
    s6 = (q6 / 4.0)           # soal 6 (0..4)
    s7 = (q7 / 3.0)           # soal 7 (0..3)
    s8 = (q8 / 4.0)           # soal 8 (0..4)
    s9 = (q9 / 2.0)           # soal 9 (0..2)
    s10 = (q10 / 3.0)         # soal 10 (0..3)

    # Skala agar total 0..10 (setiap s in 0..1 lalu dikali 1 dan dijumlahkan)
    manual_score = (s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10) * 1.0

    # Level berdasarkan rentang total 0..10
    if manual_score < 2:
        label = 'Sangat Rendah'
    elif manual_score < 4:
        label = 'Rendah'
    elif manual_score < 6:
        label = 'Sedang'
    elif manual_score < 8:
        label = 'Tinggi'
    else:
        label = 'Sangat Tinggi'

    return jsonify({
        'level': label,
        'score': float(manual_score),
        # optional: include per-question scores for debugging
        'detail_scores': [s1, s2, s3, s4, s5, s6, s7, s8, s9, s10]
    })

if __name__ == '__main__':
    app.run(port=5000)
