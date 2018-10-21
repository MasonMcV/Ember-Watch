import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage

def logToFirebase(data):
    cred = credentials.Certificate("ember-watch-cb6ea-firebase-adminsdk-nz491-27c62915f8.json")
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'ember-watch-cb6ea.appspot.com'
    })
    db = firebase_admin.firestore.client()
    emberWatch = db.collection(u'Ember-Watch')
    emberWatch.add(data)

