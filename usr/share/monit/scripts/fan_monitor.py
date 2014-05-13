#!/usr/bin/python

"""
This script checks that the fan speeds are within thresholds.

The exit status of this script is inspected by monit, which issues
alerts for fans.

The following exit codes are defined:

0   -- all fans running normally
100 -- unexpected fan count detected
101 -- unable to read config file

Any other exit code indicaes one or more fans is not with the
specified thresholds.

"""

##
## Copyright 2012 Cumulus Networks, Inc.
## All rights reserved.
##

## Perhaps read a style guide
## http://google-styleguide.googlecode.com/svn/trunk/pyguide.html

import sys
import os
import re
import ConfigParser
import array
import subprocess
import tempfile

log_en = False
config_file = "/etc/fan_monitor/fan_monitor.cfg"

def log(msg):
    if log_en:
        print msg

def log_err(msg):
    sys.stderr.write( "Fan monitor: " + msg + "\n")

def get_sensors(sensor_type, sensor_file):
    sensor_args = ["/usr/bin/sensors", "%s-*" % (sensor_type)]

    retry = 0
    while True:
        try:
            subprocess.check_call(sensor_args, stdout=sensor_file)
        except Exception, e:
            if retry < 3:
                log_err('exception, retry sensors: %d' % retry)
            else:
                raise e

        sensor_file.seek(0,2)
        if sensor_file.tell() == 0:
            if retry < 3:
                log_err('no data, retry sensors: %d' % retry)
            else:
                raise RuntimeError('no output from sensors')
        else:
            break

        retry += 1

    sensor_file.seek(0)

def main():

    if (len(sys.argv) > 1):
        if sys.argv[1] == "-d":
            global log_en
            log_en = True

    config = ConfigParser.RawConfigParser()
    log("Reading configuration from " + config_file)
    config.read(config_file)

    try:
        num_fans = config.getint('Control', 'num_fans')
        log("num_fans = %d" % (num_fans))
    except ConfigParser.NoSectionError, e:
        # no config file
        log_err("missing config file %s" % (config_file))
        sys.exit(101)

    if num_fans == 0:
        # Nothing to do
        sys.exit(0)

    sensor_type = config.get('Control', 'sensor_type')

    fan_high = array.array('H')
    for i in range(num_fans):
        fan_high.append( config.getint('Fans', 'fan%d_high' % (i+1)))
        log("%d fan_high: %d" % (i+1, fan_high[i]))

    # read sensor data
    sensor_file = tempfile.TemporaryFile()
    get_sensors(sensor_type, sensor_file)

    # look for -- fan1:       4800 RPM  (div = 4)
    fan_sensor = []
    fan_count = 0
    prog = re.compile("^fan\d:  *(\d+) RPM")
    for line in sensor_file:
        result = prog.match(line)
        if result is not None:
            log("found speed: " + result.group(1))
            fan_sensor.append(int(result.group(1)))
            fan_count += 1

    sensor_file.close()

    if fan_count != num_fans:
        # Did not find expected number of fans
        log_err("found %u fans, but expecting to find %u" % (fan_count, num_fans))
        sys.exit(100)

    rc = 0
    for i in range(num_fans):
        if fan_sensor[i] > fan_high[i]:
            log_err("Fan #%d: fan speed %u is over threshold %u" % ((i+1), fan_sensor[i], fan_high[i]))
            rc += 1

    sys.exit(rc)

if __name__ == '__main__':
    main()
