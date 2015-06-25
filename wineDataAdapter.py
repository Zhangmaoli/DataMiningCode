fileIn = open('wine.data', 'r')
data = []
tagsStr = []

for line in fileIn.readlines():
    dataLine = line.split(',')
    if len(dataLine) > 10:
        tagsStr.append(dataLine[0])
        dataLine = dataLine[1:]
        data.append(' '.join(dataLine))
fileIn.close()

fileOut = open('wine.data.txt', 'w')
for ele in data:
    fileOut.write(ele + '\n')
fileOut.close()

fileOut = open('wine.data.tags.txt', 'w')
for tag in tagsStr:
    fileOut.write(tag + '\n')
fileOut.close()
