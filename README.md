<img width="3188" height="1202" alt="frame (3)" src="https://github.com/user-attachments/assets/517ad8e9-ad22-457d-9538-a9e62d137cd7" />


# BLINK APP 🎯


## Basic Details
### Team Name: FUBAR


### Team Members
- Team Lead: P.S.Krishnaprasad - Mar Athanasius College Of Engineering
- Member 2: Joel Baby - Mar Athanasius College Of Engineering

### Project Description

Do you find your eyes useful ? Do you like them,well not anymore a simple app to see(or not see) things in a new way. An app that only works when you close your eyes.

### The Problem (that doesn't exist)

Apps today cater only to open eyes. That's descrimination. With this app we can make the world finally EQUAL.

### The Solution (that nobody asked for)

I first created a Python script which uses MediaPipe’s(opencv didn't work) face mesh to detect my eyes through the webcam feed, calculates how open or closed they are, and when I blink for a few frames in a row, it increments a counter. This counter is served over a mini Flask API so that any other program can ask “Hey, is the user’s eyes open or closed and how many times have they blinked?”. It also displays the live camera feed with the EAR (Eye Aspect Ratio) and the current eye status overlay which is connected to a flutter frontend which has a video page and a game page.

## Technical Details
### Technologies/Components Used
For Software:
- Python,Flutter
- Flask,Mediapipe
- Flask,OpenCV,NumPy,http,video_player
- Hands

### Implementation
I first created a python script which detects whether your eyes are open or not(used OpenCV didn't work for some 'unknown reason' (I was dumb)) that's when ma boy gpt5o introduced me to mediapipe and EAR(Eye Aspect Ratio)'s and
baisically it's a mathematical measurement which tells the program how open or close the eyes are and uses six different landmarks or features to map each eye so in theory you can cheat the program by opening your eyes just a teeny tiny bit.
Then i used a mini flask api to connect the backend server (my laptop,hence its Ip address there and here,i don't know how safe this is but at this point i am too lazy to change it) to the flutter front end which has a simple video player and tetris game pages.
# Installation
- Download from GitHub(then open Terminal)
- run :- pip install -r requirements.txt
- install flutter,android studio and a flutter emulator

# Run
- run blink.py to start the backend server(don't close)
- change the ip address to the ip adress of your system
- pen another vs code terminal
- cd App/blink1 
- run the command :- flutter run lib/main.dart

### Project Documentation

# Screenshots (Add at least 3)

<img width="1277" height="1035" alt="Screenshot 2025-08-09 041637" src="https://github.com/user-attachments/assets/c1d9a417-44c1-4d01-b5a5-bde504adad2a" />

![blink and u dye]
*The window that opens when you run blink.py need to be constantly running in the background for the app to work(blurred because not the most handsome face)*

<img width="1093" height="924" alt="Screenshot 2025-08-09 042346" src="https://github.com/user-attachments/assets/ec3d9b09-6526-41ea-a20d-3544aee26b7c" />

![open close]
*shows server side logs*

<img width="633" height="1410" alt="Screenshot 2025-08-09 042723" src="https://github.com/user-attachments/assets/e3431bdd-d8f9-45ee-9721-9dfee839577e" />
<img width="633" height="1391" alt="Screenshot 2025-08-09 042738" src="https://github.com/user-attachments/assets/575cf4c3-f4c1-4b86-8c65-844dfdfb884a" />

![videos and tetris]
*static because images are static and eyes are open*

# Diagrams

<img width="1536" height="1024" alt="diagram" src="https://github.com/user-attachments/assets/2ed50aae-654e-4116-8acd-65e89fd47a07" />

*The design is very human and easy to undersatand so no explanation required(no really it seems unwantedly compliacted but its 'simple'(I hate the moment I started working on this project))*

### Project Demo
# Video
https://drive.google.com/file/d/17_hQOdhFYLUfgzHSwkXybUpKt5kT_4Lg/view?usp=sharing
https://drive.google.com/file/d/1Q_1eHhSgRY2LNaW2KTq6A_SZgE4bklIE/view?usp=sharing
*how to start blink backend and what the app does in tandum with the front end*

# Additional Demos
[Add any extra demo materials/links]

## Team Contributions
- [Name 1]: P.S.Krishnaprasad
- [Name 2]: Joel Baby

---
Made with ❤️ at TinkerHub Useless Projects 

![Static Badge](https://img.shields.io/badge/TinkerHub-24?color=%23000000&link=https%3A%2F%2Fwww.tinkerhub.org%2F)
![Static Badge](https://img.shields.io/badge/UselessProjects--25-25?link=https%3A%2F%2Fwww.tinkerhub.org%2Fevents%2FQ2Q1TQKX6Q%2FUseless%2520Projects)



