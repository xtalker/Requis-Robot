import oyaml as yaml  # Note PyYaml doesn't preserve the order of key/values!
import re, csv
from robot.api.deco import keyword

#print "*WARN* Running: Python_Methods.py"


def Create_CSV(csv_file, data_group, header):

  #  Create a CSV file for uploading test data passed from YAML format
  #  Note: 'data_group' is a section of the test data yaml file. Called from Robot with:
  #      Create CSV  ${csv_file}  @{data_group} ${header}

  outfile = open(csv_file,"w")
  outfile.write(header)

  # Get array of all assets in the group
  for item in data_group:
    #print "*WARN*",item["name"]

    # Get all options for each asset
    #print "*WARN* NAME: ----",item["name"],"----"
    outfile.write("\n")

    # Write each option to csv file
    for option in item: 

      if item[option] is None:
          #print "*WARN* NONE DETECT: ",item[option]
          item[option] = ""

      #print "*WARN* OPTION:",item[option]

      outfile.write('"' + str(item[option]) + '"')
      outfile.write(',')
      
  outfile.close()

  return("DONE")


def Create_Bid_CSV(csv_file, item_data_group, bid_data_group, header):

  #  Create a CSV file for uploading bid from test data passed in YAML format
  #
  #  This will combine item data with bid information (based on item number) to create a bid csv.
  #
  #  Note: 'data_group' is a section of the test data yaml file. Called from Robot with:
  #      Create bid CSV  ${csv_file}  ${item_data_group}  ${bid_data_group}  ${header}

  outfile = open(csv_file,"w")
  outfile.write(header)

  # Get each item in the group
  for item in item_data_group:

    #print "*WARN* ITEM: ----",item["description"],"----"
    outfile.write("\n")

    # Get bid in the group
    for bid in bid_data_group:

      # Combine item and bid data if they have the same "item number"
      if item["item_number"] == bid["item_number"]:
  
        #print "*WARN* BID: ----",bid["bid_total_price"],"----"

        # Item data
        outfile.write('"' + str(item["item_number"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(item["commodity-tag"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(item["description"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(item["quantity"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(item["unit"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(item["delivery_site"]) + '"')
        outfile.write(',')

        # Bid data
        outfile.write('"' + str(bid["bid_delivery_time"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(bid["bid_unit_price"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(bid["bid_total_price"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(bid["bid_currency"]) + '"')
        outfile.write(',')
        outfile.write('"' + str(bid["bid_remarks"]) + '"')

  outfile.close()

  return("DONE")


def Read_CSV(filename):
    
  # Creates a keyword named "Read CSV"
  #
  # This keyword takes one argument, which is a path to a .csv file. It
  # returns a list of rows, with each row being a list of the data in 
  # each column.
  
  data = []
  with open(filename, 'rb') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
      data.append(row)
  return data


def Make_test_data_unique(template_file, test_data_file, unique_id):

  # Add unique ids to assets in a test data template file and create a test data file

  #print "*WARN* TEMP File: ",template_file
  #print "*WARN* OUT File:  ",test_data_file

  infile =  open(template_file, 'r')
  outfile = open(test_data_file, 'w')

  try:
    content = infile.read()
  except IOError:
    print ("*WARN* Can't open asset template file")
    return 0

  content_new = re.sub('ID____', 'ID-' + str(unique_id), content, flags = re.M)

  try:
    outfile.write(content_new)
  except IOError:
    print ("*WARN* Can't create new asset data file")
    return 0

  return("DONE")