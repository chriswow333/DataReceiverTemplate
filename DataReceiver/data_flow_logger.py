from ast import literal_eval
import sys
import logging
from logging.handlers import TimedRotatingFileHandler
import traceback

import json
import os 
import time
import datetime
import codecs

class DataFlowLogger(object):
  def __init__(self, **kaws):
    self.config = kaws['config']
    self.logger = kaws["logger"]
    self.data_flow_logger_abspath = kaws["data_flow_logger_abspath"]
  def log_file(self, message):
    try:
      date_now = datetime.datetime.now().strftime("%Y-%m-%d")
      file_abspath = self.data_flow_logger_abspath + "-" + date_now
      message["datetime"] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
      with open(file_abspath, "a") as data_flow_logerr_file:
        data_flow_logerr_file.write(str(message)  + ",\n")
    except Exception as e: 
      self.logger.error(traceback.format_exc())
    
