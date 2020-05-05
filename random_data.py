#!/bin/python
import argparse
from bs4 import BeautifulSoup
import csv
import json
import random
import re
import requests
import string


parser = argparse.ArgumentParser(
    description='Random data generator')
parser.add_argument('outfile', 
                    help='Provide an output file (.json or .csv)')
parser.add_argument('-u', '--users', action='store_true',
                    help='Generate data for users')
parser.add_argument('-s', '--students', action='store_true',
                    help='Generate data for students')
parser.add_argument('-t', '--teachers', action='store_true',
                    help='Generate data for teachers')
parser.add_argument('-c', '--classes', action='store_true',
                    help='Generate data for classes')
args = parser.parse_args()

outfile = args.outfile
file_type = outfile.split('.')[1]

arr = []
import sys
if args.users:
    n = int(input('How many names do you want?: ')) // 5
    for i in range(n):
        page = requests.get('https://www.behindthename.com/random/random.php?number=2&sets=5&gender=both&surname=&randomsurname=yes&norare=yes&usage_eng=1%27')
        soup = str(BeautifulSoup(page.content, 'html.parser'))
        name_search = re.findall(r'(/name/\w*">)(\w*)', soup)
        a = [x[1] for x in name_search]
        for i in range(0, len(a), 3):
            if i + 2 < len(a):
                arr.append([a[i] + ' ' +  a[i+1]  + ' ' + a[i+2]])

    if file_type.lower() == 'json':
        json_array = []
        for names in arr:
            for name in names:
                data = dict()
                fname = name.split()[0]
                mname = name.split()[1]
                lname = name.split()[2]
                data['first_name'] = fname
                data['middle_name'] = mname
                data['last_name'] = lname
                data['phone_number'] = random.randint(100000000, 999999999)
                data['email'] = fname + '@test-domain.com'
                json_array.append(data)
        with open(outfile, 'a') as outfile:
                json.dump(json_array, outfile)
        print('File was saved as', args.outfile)

    elif file_type.lower() == 'csv':
        csv_array = []
        for names in arr:
            for name in names:
                a = []
                a.append(name.split()[0])
                a.append(name.split()[1])
                a.append(random.randint(100000000, 999999999))
                a.append(name.split()[0] + '@test-domain.com')
                csv_array.append(a)
        with open(outfile, 'a', newline='') as file:
            writer = csv.writer(file)
            for row in csv_array:
                writer.writerow(row)
        print('File was saved as', outfile)

elif args.classes:
    n = int(input('Number of classes: '))
    classes = ['SDD', 'WDD', 'ALDS', 'SSS1']
    for i in range(n):
        dict_val = dict()
        # dict_val['class_name'] = "".join([random.choice(string.ascii_letters)
        #                           .upper() for x in range (0, random.randint(2, 4))])
        dict_val['class_name'] = random.choice(classes)
        dict_val['class_total_hours'] = random.randint(5, 50)
        dict_val['class_difficulty'] = random.randint(1, 10)
        arr.append(dict_val)

    with open(outfile, 'a') as outfile:
            json.dump(arr, outfile)
    print('File was saved as', args.outfile)

elif args.students:
    n = int(input('Number of students: '))
    for i in range(n):
        dict_val = dict()
        dict_val['user_id'] = random.randint(1, 200)
        dict_val['current_semester'] = 2001
        dict_val['programme_id'] = random.randint(1, 4)
        dict_val['semester_tuition'] = random.randint(10000, 150000)
        arr.append(dict_val) 

    with open(outfile, 'a') as outfile:
            json.dump(arr, outfile)
    print('File was saved as', args.outfile)

          
