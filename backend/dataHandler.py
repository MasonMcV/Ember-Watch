import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage


class dataHandler(object):
    def __init__(self):
        self.cred = credentials.Certificate("ember-watch-cb6ea-firebase-adminsdk-nz491-27c62915f8.json")
        firebase_admin.initialize_app(self.cred, {
            'storageBucket': 'ember-watch-cb6ea.appspot.com'
        })
        
    #source & target are str files
    def downloadFile(self, source, target):
        self.bucket = storage.bucket()
        self.bucket.get_blob(source)
        self.bucket.download_to_filename(target)
    
    #fields is list of str 
    def getData(self, docID, fields):
        self.db = firebase_admin.firestore.client()
        self.emberWatch = self.db.collection(u'Ember-Watch')
        self.snap = self.db.document(self.emberWatch.id, docID).get()
        self.data = []
        self.doc = self.snap.to_dict()
        for field in fields:
            self.data.append(self.doc.get(field))
    
        return self.data


