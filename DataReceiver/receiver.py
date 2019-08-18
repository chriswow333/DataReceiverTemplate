from ast import literal_eval
import sys
import logging
from logging.handlers import TimedRotatingFileHandler
import traceback
import os 
import datetime
import time
import uuid
import shutil
import subprocess
import argparse
import json


import yaml
import pyinotify

from db import *

from data_flow_logger import *

global config
config = None
global logger
logger = None
global args
args = None

# if get this error msg : WD=-1, Errno=No space left on device (ENOSPC)
# sudo sysctl fs.inotify.max_user_watches=163840
# or you can edit /proc/sys/user/max_inotify_watches


class FileEventHandler(pyinotify.ProcessEvent):  
  def __init__(self):
    self.receiver = DataReceiver()     
    self.data_receiver_logger = DataFlowLogger(
      config=config, 
      logger=logger,
      data_flow_logger_abspath = config["data_flow_logger"]["receiver"]["file_abspath"])
    
  def process_IN_CLOSE_WRITE(self, event):
    try:
       # logger
      data_flow_message = {
        "pathname":event.pathname,
        "status"  :"Received",
        "receiver_status":"receiver_status"
      }
      self.data_receiver_logger.log_file(data_flow_message)
      if os.path.isfile(event.pathname):
        if args.state == "MASTER":
          self.receiver.master(event.pathname)
        elif args.state == "BACKUP":
          self.receiver.backup(event.pathname)
    except Exception as e: 
      logger.error(traceback.format_exc())
  def process_IN_CREATE(self, event):
    try:
      if os.path.isdir(event.pathname):
        wm.add_watch(event.pathname, pyinotify.ALL_EVENTS, rec=True)
    except Exception as e: 
      logger.error(traceback.format_exc())
  
class DataReceiver(object):
  def __init__(self):
    self.mysql_config = {
      "host":config["mysql"]["host"],
      "port":config["mysql"]["port"],
      "user":config["mysql"]["user"],
      "password":config["mysql"]["password"],
      "database":config["mysql"]["database"],
      "pool_size":config["mysql"]["pool_size"]
    }

    self.mysql_pool = MySQLDB(**self.mysql_config)

    self.data_process_logger = DataFlowLogger(
      config=config, 
      logger=logger,
      data_flow_logger_abspath = config["data_flow_logger"]["process"]["file_abspath"])
    
  def backup(self, pathname):
    try:
      ## Do something in backup mode ...
      
    except Exception as e:
      logger.error(pathname)        
      logger.error(traceback.format_exc())


  def master(self, pathname):
    try:
      
      # logger
      data_flow_message = {
        "pathname":"pathname",
        "state":"state",
        "processors":"processors"
      }
      self.data_process_logger.log_file(data_flow_message)

      # Do something in master mode ...
       
    except Exception as e:
      logger.error(pathname)
      logger.error(traceback.format_exc())

    
def parsing_arguments():
  parser = argparse.ArgumentParser()
  parser.add_argument('-f', '--conf', help='config file path', metavar='conf')
  parser.add_argument('-s', '--state', help='data receiver state', metavar='state')
  return parser

if __name__ == "__main__":
  args = parsing_arguments().parse_args()


  config = yaml.safe_load(open(args.conf))

  logger = logging.getLogger("Data Receiver")
  logger.setLevel(logging.INFO)

  handler = TimedRotatingFileHandler(filename=config["log"]["error"]["path"],
                                      when="m",
                                      interval=1,
                                      backupCount=5)
  logger.addHandler(handler)

  source_path = config['data_workspace']['source_path']

  try:
    # watch manager
    global wm
    wm = pyinotify.WatchManager()
    wm.add_watch(source_path, pyinotify.ALL_EVENTS, rec=True)

    # event handler
    eh = FileEventHandler()

    # notifier
    notifier = pyinotify.Notifier(wm, eh)
    notifier.loop()
  except Exception as e: 
    logger.error(traceback.format_exc())

