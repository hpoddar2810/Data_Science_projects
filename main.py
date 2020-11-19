import gspread
from bs4 import BeautifulSoup as bst
from requests import get
from datetime import date
import numpy as np

def lambda_handler(event, context):
    print("###")
    gc = gspread.service_account(filename='credential.json')
    sh = gc.open_by_key('1wePUuZHpzG4NO_7MUkWOBSZv3Akf0ih-7jp0j5_x214')
    sheet = sh.sheet1
    #
    #res1= sheet.get_all_records()
    #sheet.append_row([1,1,1])
    #print(res1)

    url = 'https://www.worldometers.info/coronavirus/'
    response = get(url)
    html_soup = bst(response.text, 'html.parser')

    table_content = html_soup.find('table', {'id':'main_table_countries_today'})
    # return table_content
    # print(table_content)
    main_content = table_content.find('tbody')
    # print("###################################################")
    # print(main_content)

    def check_id(tag):
        valid_style = ["","background-color:#EAF7D5"]
        if tag.has_attr('class'):
            return tag['class'] == 'total_row_world'
        if tag.has_attr('style'):
            return tag['style'] in valid_style

        return False

    def convert_to_integer(s):
        res = ""
        for c in s:
            if c != ',' and c != ' ':
                res += c

        return int(res) if res != '' else 0

    def add(A, res):
        A.append([res[0]])

        for i in range(1,7):

            if res[i] == "" or res[i] == 'N/A':
                A[-1].append(0)
            elif res[i][0] == '+':
                A[-1].append(convert_to_integer(res[i][1:]))
            else:
                A[-1].append(convert_to_integer(res[i]))

    row_content = main_content.find_all(check_id)
    # print(row_content)
    # print("##################################################################")
    # print(len(row_content))
    A = []
    country = ['USA', 'India', 'Brazil', 'Russia', 'China', 'UK', 'Iran', 'Italy', 'Iraq', 'France']
    for row in row_content:
        li = row.find_all('td')

        res = []
        if li[1].text in country:
            for i in li[1:8]:
                res.append(i.text)
            add(A, res)
    print(A)

    #print(A)
    todaydate = str(date.today())
    # def myconverter(o):
    #     if isinstance(o, date):
    #         return o.__str__()
    # afterdump = json.dumps(todaydate, default=myconverter)
    for row in A:
        sheet.append_row(row + [todaydate])
        #print(row)
