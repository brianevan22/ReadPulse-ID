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
    q3 = int(data.get('enjoyment_scale', 0))         # 0..4
    q4 = int(data.get('has_personal_books', 0))      # 0..1
    q5 = int(data.get('format_preference', 0))       # 0..3
    q6 = int(data.get('genre_variety', 0))           # 0..4
    q7 = int(data.get('purpose', 0))                 # 0..3
    q8 = int(data.get('reading_habit_duration', 0))  # 0..4
    q9 = int(data.get('discussion_habit', 0))        # 0..3
    q10 = int(data.get('reading_community', 0))      # 0..3

    # Konversi tiap soal ke skor 0..1 sesuai aturan:
    s1 = q1 * 0.25                # soal 1 (5 pilihan)
    s2 = q2 * 0.25                # soal 2 (5 pilihan)
    s3 = q3 * 0.25                # soal 3 (5 pilihan)
    s4 = 0.5 + q4 * 0.5           # soal 4 (2 pilihan => 0.5 atau 1.0)
    s5 = 0.25 + q5 * 0.25         # soal 5 (4 pilihan, terendah 0.25)
    s6 = q6 * 0.25                # soal 6 (5 pilihan termasuk 0 jenis)
    s7 = 0.25 + q7 * 0.25         # soal 7 (4 pilihan, terendah 0.25)
    s8 = q8 * 0.25                # soal 8 (5 pilihan)
    s9 = 0.25 + q9 * 0.25         # soal 9 (4 pilihan)
    s10 = 0.25 + q10 * 0.25       # soal 10 (4 pilihan)

    manual_score = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10  # 0..10

    # Level berdasarkan rentang total
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
