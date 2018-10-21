class NasaData(object):
    def __init__(self):
        source = open('NasaData.csv', 'r')
        self.NasaData = []
        lines = source.readlines()
        for l in range(1, len(lines)):
            line = lines[l]
            datapoint = line.split(',')
            data = {
                'lat' : datapoint[0],
                'long' : datapoint[1],
            }
            self.NasaData.append(data)
    
    def getData(self, index, key):
        return self.NasaData[index][key]