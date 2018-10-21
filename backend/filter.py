import nasaData
import math

def filterData(lon, lat):
    dist_of_1_deg_long = math.cos(math.radians(lat)) * 68.71#len of degree at equator(miles)
    dist_of_1_deg_lat = 69
    maxDiff = 25#(miles)
    data = nasaData.NasaData()
    for point in data.NasaData:
        datapoint = {}
        for key in point:
            datapoint[key] = point[key]
        if (abs(lon - float(datapoint['long'])) * dist_of_1_deg_long < maxDiff) & (abs(lat - float(datapoint['lat'])) * dist_of_1_deg_lat < maxDiff):
            return True
        else:
            return False