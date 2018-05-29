#!/usr/bin/env python3

import os, sys, signal, argparse, subprocess, time

#modulepath = cwd + "/modules/"
#sys.path.append(modulepath)
#print (sys.path[-1])

import modules.m2ua.m2ua as m2ua
import modules.m2ua.m2uacheck as m2uacheck
#import modules.scrformer as scrformer
import modules.confparse as confparse
import modules.scriptparse as scriptparse

from html.parser import HTMLParser
from xml.sax.handler import DTDHandler

from lxml import etree


def File_Existence_Check(file_path):
    if type(file_path) != str:
        raise argparse.ArgumentTypeError("argument must be string")
    else:
        if not os.path.exists(file_path):
            raise argparse.ArgumentTypeError("file \"%s\" does not exist" % file_path)
        else:
            return file_path

def Define_Args():
    args = argparse.ArgumentParser(description="List of possible command line arguments")
    args.add_argument("-s", "--script", action="store", type=File_Existence_Check, required=True, dest="script", help="set script")
    args.add_argument("-c", "--config", action="store", type=File_Existence_Check, required=False, dest="config", help="set global config file")
    return args

class Script_Former:

    def Body_Former(self, scrypt, config, path, test_file):
        code = 0
        strcount = 0
        scenopenflag = False
        recvbuf = 15000
        m2ua_ppid = "0x02000000"
        # XML parse and validate
        xmlparser = etree.XMLParser(strip_cdata=False)
        tree = etree.parse(path, xmlparser)
        docinfo = tree.docinfo
        dtdfilename = docinfo.doctype.split('"', 2)
        dtdfilepath = cwd + "/tests/xml/" + dtdfilename[1] 
        dtd = etree.DTD(dtdfilepath)        
        if dtd.validate(tree):    # If valid XML file
        	root = tree.getroot()
        	testname = root.attrib # Scriptname
        	for line in root:
        		if line.tag == "sock_open":
        			proto = line.attrib["proto"]
        			if line.attrib["transport"] == "sctp":
        				test_file.write ("\n#Create SCTP socket\n")
        				test_file.write ("recv_buf = {0}\n".format(recvbuf))
        				test_file.write ("sk{0} = sctp.sctpsocket_tcp(socket.AF_INET)\n".format(line.attrib["local"]))
        				try: 
        					xxx = line.attrib["timeout"]
        					test_file.write ("sk{0}.settimeout({1})\n".format(line.attrib["local"], int(line.attrib["timeout"])))
        				except KeyError:
        					test_file.write ("sk{0}.settimeout({1})\n".format(line.attrib["local"], 30))
        			elif line.attrib["transport"] == "tcp":
        				pass
        			else:
        				pass
        			test_file.write ("sk{0}.bind((address{0}, port{0}))\n".format(line.attrib["local"]))
        			test_file.write ("sk{0}.connect((address{1}, port{1}))\n".format(line.attrib["local"], line.attrib["remote"]))
        		if line.tag == "sock_close":
        			test_file.write ("\n#Close SCTP socket\n")
        			test_file.write ("sk{0}.close()\n".format(line.attrib["local"]))
        		if line.tag == "send":
        			sendinfo = executor.Values_Exec(line.text.strip(), 'send')
        			if sendinfo[2]:
	        			test_file.write ("\nmessage = builder.Build_{0}_Message({1})\n".format(sendinfo[1], sendinfo[3]))
	        		else:
	        			test_file.write ("\nmessage = builder.Build_{0}_Message()\n".format(sendinfo[1]))
        			if proto == "m2ua":
        				test_file.write ("sk{0}.sctp_send(message,ppid={1})\n".format(line.attrib["socket"], m2ua_ppid))
        		if line.tag == "recv":
        			recvinfo = executor.Values_Exec(line.text.strip(), "recv")
        			if recvinfo[1] == "NO MESSAGE":
        				test_file.write ("\ntry:\n")
        				test_file.write ("        message = sk{0}.recv({1})\n".format(line.attrib["socket"], recvbuf))
        				test_file.write ("        print ('NOK')\n")
        				test_file.write ("except socket.timeout:\n")
        				test_file.write ("        print('No message OK')\n")
        			else:
        				test_file.write ("\nmessage = sk{0}.recv({1})\n".format(line.attrib["socket"], recvbuf))
        				test_file.write ("obj_message = parser.Parse_Message(message)\n")
        				if recvinfo[2]:
        					test_file.write ("validation_result = validator.Validate_Message_W_Params(obj_message, '{0}', '{1}', {2})\n".format(line.attrib["class"], recvinfo[1], recvinfo[3]))
        				else:
        					test_file.write ("validation_result = validator.Validate_Message(obj_message, '{0}', '{1}')\n".format(line.attrib["class"], recvinfo[1]))

    def Form_M2UA_Header(self, test_file):
        test_file.write ("#!/usr/bin/env python3\n\n")
        test_file.write ("import logging\n")
        test_file.write ("import socket\n")
        test_file.write ("import sctp\n")
        test_file.write ("import sys\n")
        test_file.write ("import modules.m2ua.m2ua as m2ua\n\n")

    def Form_Config_Param(self, config, test_file):
#        ConfParser = confparse.Config_Parser()
#        config = ConfParser.Parse_Config(gconfpath)
        test_file.write ("#Config parameters values\n")
        i = 0
        while i < len(config.sock_id):
            test_file.write ("address{0} = '{1}'\n".format(config.sock_id[i], config.sock_ipaddr[i]))
            test_file.write ("port{0} = {1}\n".format(config.sock_id[i], config.sock_port[i]))
            i += 1
        i = 0
        while i < len(config.sigtran_par_id):
            test_file.write ("{1}{0} = {2}\n".format(config.sigtran_par_id[i], config.sigtran_par_type[i], config.sigtran_par_value[i]))
            i += 1        
        test_file.write ("\n#Message builder and parser\n")
        test_file.write ("builder = m2ua.Message_Builder()\n")
        test_file.write ("parser = m2ua.Message_Parser()\n")
        test_file.write ("validator = m2ua.Parameters_Validator()\n")

    def File_Former(self, script, config):
        self.Form_M2UA_Header()
        self.Form_Config_Param(config)
        self.Body_Former() 




        return path, code

# Определяем и сохраняем текущий путь к файлу - это корень
try:
    cwd = os.path.dirname(os.path.realpath(__file__))
    os.chdir(cwd)
except:
    pass

# Config path
paths = Define_Args()
if paths.parse_args().config:
	gconfpath = paths.parse_args().config
else:
	gconfpath = os.path.normpath(os.path.dirname(paths.parse_args().script) + "/../config.json")
	
# Parse test script
ScrParser = scriptparse.Script_Parser()
testconf = ScrParser.Parse_Script(paths.parse_args().script)

# Parse config
ConfParser = confparse.Config_Parser()
config = ConfParser.Parse_Config(gconfpath)

# Execute test script parameters
executor = m2ua.Config_Executor()

# Do preconf
pass

# test execute
if testconf.type == "sequential":
	for test in testconf.test:
		if test[5]:
			print ("Test ({0}:{1}) will not be executed, because bug in DUT software exist".format(test[0], test[1]))
		else:
			for value in test[2]: # mdfy for more than one value
				if value == "m2ua":
					test_file = open("run.py", "w")     # make try construction
					ScrRunner = Script_Former()
					ScrRunner.Form_M2UA_Header(test_file)
					ScrRunner.Form_Config_Param(config, test_file)
					scrName = os.path.dirname(paths.parse_args().script) + "/" + test[3]
					ScrRunner.Body_Former(test, config, scrName, test_file)
					test_file.close()     # make try construction
					os.chmod("run.py", 0o777)

					if test_file:
						print ("Test ({0}:{1}) starts".format(test[0], test[1]))
						subprocess.run("./run.py")

				else:
					pass
				time.sleep(test[4])
else:
	pass



# Do postconf
pass

code = 127
sys.exit(code)
