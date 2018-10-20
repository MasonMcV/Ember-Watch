import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.Certificate("ember-watch-cb6ea-firebase-adminsdk-nz491-27c62915f8.json")
firebase_admin.initialize_app(cred)
db = firebase_admin.firestore.client()

print('done')
