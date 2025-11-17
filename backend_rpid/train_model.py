import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import accuracy_score
import joblib

# 1. Baca dataset
df = pd.read_csv('reading_interest_data.csv')
# Kalau CSV kamu ternyata pakai titik koma (;), pakai ini:
# df = pd.read_csv('reading_interest_data.csv', sep=';')

# 2. Pisahkan fitur dan label
X = df[[
    'frequency_per_week',
    'minutes_per_day',
    'enjoyment_scale',
    'has_personal_books',
    'format_preference',
    'genre_variety',
    'purpose',
    'reading_habit_duration'
]].values

y = df['label'].values  # 0 = rendah, 1 = sedang, 2 = tinggi

# 3. Scaling / normalisasi ke rentang 0–1
scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)

# 4. Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42
)

# 5. Bangun model neural network (MLP)
model = MLPClassifier(
    hidden_layer_sizes=(16, 8),  # dua hidden layer: 16 & 8 neuron
    activation='relu',
    max_iter=1000,
    random_state=42
)

# 6. Training
model.fit(X_train, y_train)

# 7. Evaluasi
y_pred = model.predict(X_test)
acc = accuracy_score(y_test, y_pred)
print("Test accuracy:", acc)

# 8. Simpan model dan scaler
joblib.dump(model, 'reading_interest_model.pkl')
joblib.dump(scaler, 'reading_interest_scaler.pkl')

print("Model saved to reading_interest_model.pkl")
print("Scaler saved to reading_interest_scaler.pkl")
