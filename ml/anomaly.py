import os
import joblib
import numpy as np
import pandas as pd

ML_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_FILE = os.path.join(ML_DIR, "memoryweave_personalized_isolation_forest.pkl")
SCALER_FILE = os.path.join(ML_DIR, "memoryweave_personalized_scaler.pkl")
BASELINE_FILE = os.path.join(ML_DIR, "memoryweave_training_baselines.csv")

TREND_WINDOW = 5

try:
    scaler = joblib.load(SCALER_FILE)
    model = joblib.load(MODEL_FILE)
    baselines_df = pd.read_csv(BASELINE_FILE).set_index("user_id")
    print("MemoryWeave ML artifacts loaded successfully.")
except FileNotFoundError as e:
    print(f"ML Artifact Warning: {e}")
    scaler, model, baselines_df = None, None, pd.DataFrame()

DEFAULT_BASELINE = {
    "accuracy_mean": 0.80, "accuracy_std": 0.05,
    "avg_response_latency_mean": 5.0, "avg_response_latency_std": 1.0,
    "hint_rate_mean": 0.15, "hint_rate_std": 0.05,
    "completion_rate_mean": 0.90, "completion_rate_std": 0.05
}

def detect_drift(
    user_id: str,
    latency_ms: float,
    accuracy_score: float,
    hint_rate: float = 0.0,
    completion_rate: float = 1.0
) -> dict:
    """
    Evaluates a single session response for the FastAPI endpoint.
    """
    if model is None or scaler is None:
        return {"anomaly_flagged": False, "error": "Models not loaded"}

    latency_sec = latency_ms / 1000.0
    accuracy = accuracy_score / 100.0 if accuracy_score > 1.0 else accuracy_score

    if user_id in baselines_df.index:
        user_base = baselines_df.loc[user_id].to_dict()
    else:
        user_base = DEFAULT_BASELINE

    acc_z = (accuracy - user_base["accuracy_mean"]) / max(user_base["accuracy_std"], 0.02)
    lat_z = (latency_sec - user_base["avg_response_latency_mean"]) / max(user_base["avg_response_latency_std"], 0.50)
    hint_z = (hint_rate - user_base["hint_rate_mean"]) / max(user_base["hint_rate_std"], 0.02)
    comp_z = (completion_rate - user_base["completion_rate_mean"]) / max(user_base["completion_rate_std"], 0.02)

    features = np.clip([[acc_z, lat_z, hint_z, comp_z]], -6, 6)

    # Use original DataFrame column names to eliminate Scikit-Learn UserWarning
    if hasattr(scaler, "feature_names_in_"):
        features_df = pd.DataFrame(features, columns=scaler.feature_names_in_)
    else:
        features_df = pd.DataFrame(features, columns=["accuracy_z", "latency_z", "hint_z", "completion_z"])

    features_scaled = scaler.transform(features_df)
    
    pred = model.predict(features_scaled)[0]
    anomaly_score = float(-model.decision_function(features_scaled)[0])

    return {
        "anomaly_flagged": bool(pred == -1),
        "anomaly_score": round(anomaly_score, 4),
        "latency_z": round(float(lat_z), 2),
        "accuracy_z": round(float(acc_z), 2),
        "hint_z": round(float(hint_z), 2),
        "completion_z": round(float(comp_z), 2)
    }

def calculate_slope(values):
    values = np.asarray(values, dtype=float)
    if len(values) < 2:
        return 0.0
    x = np.arange(len(values))
    return float(np.polyfit(x, values, 1)[0])

def evaluate_behavioral_state(recent_sessions_df: pd.DataFrame) -> dict:
    """
    Evaluates a user's recent session history (last TREND_WINDOW sessions)
    to classify behavioral state into: stable, temporary_deviation, persistent_change.
    """
    if len(recent_sessions_df) == 0:
        return {
            "state": "stable",
            "accuracy_trend": 0.0,
            "latency_trend": 0.0,
            "hint_trend": 0.0,
            "completion_trend": 0.0,
            "recent_anomaly_count": 0
        }

    recent = recent_sessions_df.tail(TREND_WINDOW)

    accuracy_trend = calculate_slope(recent["accuracy"].values)
    latency_trend = calculate_slope(recent["avg_response_latency"].values)
    hint_trend = calculate_slope(recent["hint_rate"].values)
    completion_trend = calculate_slope(recent["completion_rate"].values)

    anomaly_count = int(recent["is_anomaly"].sum())

    concerning_trends = 0
    if accuracy_trend < -0.008:
        concerning_trends += 1
    if latency_trend > 0.12:
        concerning_trends += 1
    if hint_trend > 0.008:
        concerning_trends += 1
    if completion_trend < -0.008:
        concerning_trends += 1

    anomaly_sequence = recent["is_anomaly"].astype(int).tolist()
    consecutive_anomalies = 0
    for value in reversed(anomaly_sequence):
        if value == 1:
            consecutive_anomalies += 1
        else:
            break

    last_anomaly = bool(recent_sessions_df.iloc[-1]["is_anomaly"])
    previous_anomalies = recent.iloc[:-1]["is_anomaly"]
    had_previous_anomaly = bool(previous_anomalies.any())
    recovery = had_previous_anomaly and not last_anomaly

    if anomaly_count == 0 and concerning_trends < 2:
        state = "stable"
    elif recovery and anomaly_count <= 2 and concerning_trends < 2:
        state = "temporary_deviation"
    elif consecutive_anomalies >= 2 or (concerning_trends >= 2 and anomaly_count >= 1):
        state = "persistent_change"
    elif concerning_trends >= 3:
        state = "persistent_change"
    else:
        state = "temporary_deviation"

    return {
        "state": state,
        "accuracy_trend": accuracy_trend,
        "latency_trend": latency_trend,
        "hint_trend": hint_trend,
        "completion_trend": completion_trend,
        "recent_anomaly_count": anomaly_count
    }

def generate_explanation(latest_session: dict, trends: dict, baseline: dict) -> str:
    """
    Generates plain-language insights for the Caregiver Dashboard.
    """
    state = trends.get("state", "stable")
    explanations = []

    acc_diff = latest_session.get("accuracy", 0.0) - baseline.get("accuracy_mean", 0.8)
    if acc_diff < -0.05:
        explanations.append(f"Accuracy is {abs(acc_diff) * 100:.1f} percentage points below the user's baseline.")

    lat_diff = latest_session.get("avg_response_latency", 0.0) - baseline.get("avg_response_latency_mean", 5.0)
    if lat_diff > 1.0:
        explanations.append(f"Response latency is {lat_diff:.1f} seconds above baseline.")

    hint_diff = latest_session.get("hint_rate", 0.0) - baseline.get("hint_rate_mean", 0.15)
    if hint_diff > 0.05:
        explanations.append("Hint usage has increased compared with baseline.")

    comp_diff = latest_session.get("completion_rate", 1.0) - baseline.get("completion_rate_mean", 0.9)
    if comp_diff < -0.05:
        explanations.append("Session completion has decreased compared with baseline.")

    if trends.get("accuracy_trend", 0.0) < -0.008:
        explanations.append("Accuracy shows a downward trend across recent sessions.")
    if trends.get("latency_trend", 0.0) > 0.12:
        explanations.append("Response latency shows an increasing trend.")
    if trends.get("hint_trend", 0.0) > 0.008:
        explanations.append("Hint usage shows an increasing trend.")
    if trends.get("completion_trend", 0.0) < -0.008:
        explanations.append("Completion rate shows a downward trend.")

    if state == "stable":
        base_message = "Recent behavior remains within the user's established behavioral baseline."
    elif state == "temporary_deviation":
        base_message = "A temporary behavioral deviation was observed, but the pattern does not currently indicate a persistent change."
    elif state == "persistent_change":
        base_message = "Multiple recent behavioral indicators show a persistent change from the user's established baseline."
    else:
        base_message = "Behavioral state could not be classified."

    if explanations:
        return f"{base_message} {' '.join(explanations)}"
    return base_message