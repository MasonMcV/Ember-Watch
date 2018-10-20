import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.Certificate("ember-watch-cb6ea-firebase-adminsdk-nz491-27c62915f8.json")
firebase_admin.initialize_app(cred)
db = firebase_admin.firestore.client()
emberWatch = db.collection(u'Ember-Watch')

data = {
    u'Test' : u'Hello World!',
    u'Proof' : True
}

emberWatch.document(u'Untitled').set(data)

#gets list of documents in collection
docs = emberWatch.get()

for doc in docs:
    print(u'{} => {}'.format(doc.id, doc.to_dict()))

print('done')
