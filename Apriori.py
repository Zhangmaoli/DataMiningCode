#coding=utf8
# Filename: Apriori.py
# Author: KellyHwong

# asistant classes and funcs
class DataImporter:
    """Import data from the 'mushroom.dat'"""
    def __init__(self,filename):
        self.filename = filename
        self.data = []
    def read_file(self):
        f = open(self.filename,'r')
        for line in f.readlines():
            l_str=line.split(' ')
            if not l_str==[]:
                l_str.pop() # pop the '\n'
            if len(l_str)>0:
                l_num = []
                for str_num in l_str:
                    l_num.append(int(str_num)) # convert to int
                self.data.append(l_num)

def sort_together(keys, values):
    zipped = zip(keys, values)
    d = {}
    for k,v in zipped:
        d[k]=v
    keys = d.keys()
    keys.sort()
    keys.reverse()
    values = list(d[k] for k in keys)
    return [keys,values]

# Apriori classes
class BasicApriori():
    """BasicApriori Class"""
    def __init__(self,data,min_sup=0.5):
        """init the class with input data and min_sup"""
        self.data = data
        self.m = len(data) # num of transactions
        self.min_sup = min_sup
        self.k = 1 # max frequent itemset
        self.transactions = map(set,data)
        self.Lk = {}
        self.support = {}
        self.rules = []
        self.conf = []
    def find_frequent_1_itemsets(self):
        self.Lk[1]=[]
        # scan the dataset once to determine the items
        for transaction in self.transactions:
            for item in transaction:
                if not [item] in self.Lk[1]:
                    self.Lk[1].append([item])
        self.Lk[1] = map(set,self.Lk[1])
        # scan again to count support
        self.support[1] = [0]*len(self.Lk[1])
        for transaction in self.transactions:
            for i in range(len(self.Lk[1])):
                if self.Lk[1][i].issubset(transaction):
                    self.support[1][i] += 1
        [self.support[1],self.Lk[1]]=sort_together(self.support[1],self.Lk[1])
        min_sup_count = self.m * self.min_sup
        for i in range(len(self.support[1])):
            if self.support[1][i] < min_sup_count:
                break
        self.Lk[1] = self.Lk[1][0:i]
        self.support[1] = self.support[1][0:i]

    def apriori_gen(self,Lk_1,k):# Lk_1 is a sets' list
        Ck = []
        lk_1 = []
        for i in range(len(Lk_1)):
            l = list(Lk_1[i])
            l.sort()
            lk_1.append(l)
        if k==2:
            for i in range(len(Lk_1)):
                for j in range(len(Lk_1)):
                    if lk_1[i][k-2] < lk_1[j][k-2]:
                        c = Lk_1[i] | Lk_1[j]
                        if self.has_infrequent_subset(c):
                            pass
                        else:
                            Ck.append(c)
        elif k>2:
            for i in range(len(Lk_1)):
                for j in range(len(Lk_1)):
                    for f in range(k-2):
                        if lk_1[i][f] == lk_1[j][f]:
                            flag = 1
                        else:
                            flag = 0
                            break
                    if flag == 1:
                        if lk_1[i][k-2] < lk_1[j][k-2]:
                            c = Lk_1[i] | Lk_1[j]
                            if self.has_infrequent_subset(c):
                                pass
                            else:
                                Ck.append(c)
        return Ck

    def has_infrequent_subset(self,c):
        for e in c:
            c_tmp = c - set([e])
            if c_tmp not in self.Lk[self.k-1]:
                return True
        return False

    def apriori(self):
        self.find_frequent_1_itemsets()
        self.k=2
        while(self.Lk[self.k-1]!=[]):
            Ck = self.apriori_gen(self.Lk[self.k-1],self.k)
            if Ck != []:
                support_k = [0]*len(Ck)
                for transaction in self.transactions:
                    for i in range(len(Ck)):
                        if Ck[i].issubset(transaction):
                            support_k[i] += 1
                [support_k, Ck]=sort_together(support_k, Ck)
                min_sup_count = self.m * self.min_sup
                for i in range(len(support_k)):
                    if support_k[i] < min_sup_count:
                        break
                Ck = Ck[0:i]
                support_k = support_k[0:i]
            else:
                support_k = []
            self.Lk[self.k] = Ck
            self.support[self.k] = support_k
            self.k += 1
        self.k -= 2 # maximal frequent itemset
        del self.Lk[self.k+1]
        del self.support[self.k+1]

    def gen_rules(self,min_conf=0):
        rules = []
        conf = []
        r = range(self.k) # 0,1,2,3
        for i in range(len(r)):
            r[i] = self.k - r[i]
        r = r[0:-1]
        for i in r:
            for j in range(len(self.Lk[i])): # self.Lk[i] is a list
            # genernate rules
                itemset = self.Lk[i][j]
                support_itemset = self.support[i][j]
                for e in itemset:
                    sub_set = itemset - set([e])
                    if len(sub_set)==1:
                        if not str(list(sub_set)) > str(list(set([e]))):
                            continue
                    for m in range(len(self.Lk[1])):
                        if self.Lk[1][m] == set([e]):
                            support_1 = self.support[1][m]
                            break
                    for m in range(len(self.Lk[i-1])):
                        if self.Lk[i-1][m] == sub_set:
                            support_sub_set = self.support[i-1][m]
                    # generate two rules
                    c = support_itemset*1.0/support_1
                    if c > min_conf:
                        rules.append(','.join(map(str,list(set([e])))) + '-->' +
                                ','.join(map(str,list(sub_set))) )
                        conf.append(c)
                    c = support_itemset*1.0/support_sub_set
                    if c > min_conf:
                        rules.append(','.join(map(str,list(sub_set))) + '-->' +
                                ','.join(map(str,list(set([e])))) )
                        conf.append(c)
        self.rules = rules
        self.conf = conf

    def print_rules(self):
        print 'frequent itemset:'
        print self.Lk
        print 'support:'
        print self.support
        for i in range(len(self.rules)):
            print self.rules[i] + ",conf=%0.3f"%self.conf[i]

    def store_rules(self,filepath):
        f = open(filepath, 'w')
        for i in range(len(self.rules)):
            f.writelines(self.rules[i] + ",conf=%0.3f"%self.conf[i] + '\n')
        f.close()

class AprioriWithConf(BasicApriori):
    """Apriori Class, with confidence"""
    def __init__(self,data,min_conf=0.8):
        BasicApriori.__init__(self,data)
        self.min_conf = min_conf
    def gen_rules(self):
        BasicApriori.gen_rules(self,self.min_conf)

# class AprioriWithHash(AprioriWithConf):
    # def __init__(self,)

class AprioriUseSample(AprioriWithConf):
    def __init__(self,data):
        sampled_data = []
        for i in range(len(data)):
            if i%2 == 0:
                sampled_data.append(data[i])
        AprioriWithConf.__init__(self,sampled_data)


def main():
    data_importer = DataImporter('mushroom.dat')
    data_importer.read_file()
    data = data_importer.data

    # basic_apriori = BasicApriori(data)
    # basic_apriori.apriori()
    # basic_apriori.gen_rules()
    # basic_apriori.store_rules('apriori.basic.txt')

    apriori_with_conf = AprioriWithConf(data)
    apriori_with_conf.apriori()
    apriori_with_conf.gen_rules()
    apriori_with_conf.store_rules('apriori.conf.txt')

    # apriori_use_sample = AprioriUseSample(data)
    # apriori_use_sample.apriori()
    # apriori_use_sample.gen_rules()
    # apriori_use_sample.store_rules('apriori.samp.txt')

if __name__ == '__main__':
    main()
