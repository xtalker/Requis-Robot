# Adding custom keywords to Selenium lib
#   (from: https://github.com/robotframework/SeleniumLibrary/tree/master/docs/extending/examples/modify_seleniumlibrary)

import inspect, os
from   robot.libraries.BuiltIn  import BuiltIn
from   SeleniumLibrary.base     import keyword
from   SeleniumLibrary.base     import LibraryComponent


class KeywordClass(LibraryComponent):

    def __init__(self, ctx):
        LibraryComponent.__init__(self, ctx)

    @keyword
    def get_browser_desired_capabilities(self):
        print ("*WARN* from:",os.path.basename(__file__),"using:",inspect.stack()[0][3])
        return self.driver.desired_capabilities


    @keyword
    # Find the first string in a table that matches search_str and return the row/col found
    # Use the anchor param when the page contains multiple tables and you want to search for a string
    # in a specific table
    def locate_table_string(self, search_str, anchor='//table'):
        #print "*WARN* from:",os.path.basename(__file__),"using:",inspect.stack()[0][3]

        # Warn if there are more than one occurance of search_str in a table
        path =  anchor + "//td/*[contains(., \"" + search_str + "\")]"
        count = len(self.driver.find_elements_by_xpath(path))

        if count > 1:
            print ("*WARN* Found",count,"occurances of: '",search_str,"', locating only the first one!")

        row_index = 0;

        row_path = anchor + "//tr"
        for row in self.driver.find_elements_by_xpath(row_path):
            columns = row.find_elements_by_tag_name("td")
            col_index = 0

            for cell in columns:
                #print "*WARN* CELL: ",cell.text

                if search_str in cell.text:
                    #print "*WARN* FOUND: ",search_str," in ROW:",row_index," COL:",col_index
                    # Returns after finding the first match, how to deal with multiple?
                    return row_index, col_index

                col_index += 1
            row_index += 1

        print ("*WARN*",inspect.stack()[0][3]," - Couldn't find:",search_str)
        return None, None



class Selenium_Extensions(object):

    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self

    def start_suite(self, name, attributes):
        sl = BuiltIn().get_library_instance('SeleniumLibrary')
        sl.add_library_components([KeywordClass(sl)])
        BuiltIn().reload_library('SeleniumLibrary')
        self.added = True