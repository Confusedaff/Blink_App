import cv2
import mediapipe as mp
import time
import numpy as np
from collections import deque
from flask import Flask, jsonify
import threading

app = Flask(__name__)
status_data = {"status": False} 

@app.route("/status")
def get_status():
    return jsonify(status_data)

def run_flask():
    app.run(host="0.0.0.0", port=5000, debug=False, use_reloader=False)

mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(
    static_image_mode=False,
    max_num_faces=1,
    refine_landmarks=True,
    min_detection_confidence=0.6,
    min_tracking_confidence=0.6
)

RIGHT_EYE = [33, 160, 158, 133, 153, 144]
LEFT_EYE  = [362, 385, 387, 263, 373, 380]

def lm_to_point(lm, w, h):
    return np.array([int(lm.x * w), int(lm.y * h)])

def eye_aspect_ratio(landmarks, indices, w, h):
    p = [lm_to_point(landmarks[i], w, h) for i in indices]
    p1, p2, p3, p4, p5, p6 = p
    def dist(a,b): return np.linalg.norm(a - b)
    vert1 = dist(p2, p6)
    vert2 = dist(p3, p5)
    hor = dist(p1, p4)
    if hor == 0:
        return 1.0
    return (vert1 + vert2) / (2.0 * hor)

EAR_THRESHOLD = 0.20   
CONSEC_FRAMES = 3      
SMOOTH_LEN = 5         

threading.Thread(target=run_flask, daemon=True).start()

cap = cv2.VideoCapture(0)
if not cap.isOpened():
    raise RuntimeError("Cannot open webcam")

closed_frames = 0
ear_history = deque(maxlen=SMOOTH_LEN)
last_status = None

try:
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        h, w = frame.shape[:2]
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = face_mesh.process(rgb)

        if results.multi_face_landmarks:
            lm = results.multi_face_landmarks[0].landmark
            left_ear  = eye_aspect_ratio(lm, LEFT_EYE, w, h)
            right_ear = eye_aspect_ratio(lm, RIGHT_EYE, w, h)
            ear = (left_ear + right_ear) / 2.0
            ear_history.append(ear)
            smooth_ear = float(np.mean(ear_history))
            cv2.putText(frame, f"EAR:{smooth_ear:.3f}", (10,30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)

            if smooth_ear < EAR_THRESHOLD:
                closed_frames += 1
            else:
                closed_frames = 0
        else:
            closed_frames = 0
            cv2.putText(frame, "No face", (10,30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,0,255), 2)

        is_closed = closed_frames >= CONSEC_FRAMES
        status_data["status"] = is_closed  

        if is_closed != last_status:
            print("EYES CLOSED" if is_closed else "EYES OPEN")
            last_status = is_closed

        cv2.putText(frame, "EYES CLOSED" if is_closed else "EYES OPEN", (10,60), 
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255,255,255), 2)

        cv2.imshow("Eye-controlled status", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

finally:
    cap.release()
    cv2.destroyAllWindows()
    face_mesh.close()
