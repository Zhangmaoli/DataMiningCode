fileIn = open('iris.data', 'r')
data = []
tags = []

for line in fileIn.readlines():
    dataLine = line.split(',')
    if len(dataLine) == 5:
        tags.append(dataLine.pop()[0:-1])
        data.append(' '.join(dataLine))
fileIn.close()

fileOut = open('iris.data.txt', 'w')
for ele in data:
    fileOut.write(ele + '\n')
fileOut.close()

fileOut = open('iris.data.tags.txt', 'w')
i = 0
for tag in tags:
    i += 1
    print '%s' % i + tag
    if tag == 'Iris-setosa':
        tagNum = 1
    elif tag == 'Iris-versicolor':
        tagNum = 2
    elif tag == 'Iris-virginica':
        tagNum = 3
    fileOut.write('%s' % tagNum + '\n')
fileOut.close()
