import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage

cred = credentials.Certificate("ember-watch-cb6ea-firebase-adminsdk-nz491-27c62915f8.json")
firebase_admin.initialize_app(cred, {
    'storageBucket': 'ember-watch-cb6ea.appspot.com'
})
db = firebase_admin.firestore.client()
emberWatch = db.collection(u'Ember-Watch')
bucket = storage.bucket()
blob = bucket.get_blob(u'wildfire-widescreen-a-1.jpg')

blob.download_to_filename(u'pic.jpeg')

data = {
   
}

#gets list of documents in collection
docs = emberWatch.get()

for doc in docs:
    print(u'{} => {}'.format(doc.id, doc.to_dict()))

print()