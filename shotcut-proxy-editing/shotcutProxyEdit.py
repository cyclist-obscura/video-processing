#!/bin/python
##################################################################################################
#   Shotcut Helper Scripts
#
#   file        shotcutProxyEdit.py
#   date        12/12/19
#   version     1.0
#   Requires    Python3.x, subprocess, shutil, os, ffmpeg
#   Author      Cyclist Obscura
#   Licence     GPL 3.0
#
###################################################################################################

# Library Imports
import sys
import os
import subprocess
import shutil
import argparse

# Global Variables
ffmpeg_cmd = "ffmpeg -y "
ffmpeg_opts = " -vf scale=-1:432 -c:v libx264 -preset ultrafast -tune fastdecode -crf 15 -g 1 -c:a ac3 "

def createProxies(inputDir):
    print("...CREATE PROXIES")

    proxyDir = inputDir + "/proxy_files/"
    print("......Creating Proxy Directory: ", proxyDir)
    try:
        os.mkdir(proxyDir)
    except OSError:
        print(".........Creation of the directory %s failed" % proxyDir)
        #print(OSError)
    else:
        print(".........Successfully created the directory %s " % proxyDir)

    print("......Creating a list of Video Files in Directory: ", inputDir)
    videoFiles = []
    for file in os.listdir(inputDir):
        if file.endswith(".mov"):
            videoFiles.append(file)
        if file.endswith(".MOV"):
            videoFiles.append(file)
        if file.endswith(".avi"):
            videoFiles.append(file)
        if file.endswith(".AVI"):
            videoFiles.append(file)
        if file.endswith(".mxf"):
            videoFiles.append(file)
        if file.endswith(".MXF"):
            videoFiles.append(file)
        if file.endswith(".mpg"):
            videoFiles.append(file)
        if file.endswith(".MPG"):
            videoFiles.append(file)
        if file.endswith(".mp4"):
            videoFiles.append(file)
        if file.endswith(".MP4"):
            videoFiles.append(file)
    for file in videoFiles:
        print(".........", file)

    print("......Creating Proxy Files ")
    for file in videoFiles:
        inputFile = inputDir + "/" + file
        proxyFile = proxyDir + "_proxy_" + file
        print(".........", inputFile, proxyFile)
        ffmpeg_run = ffmpeg_cmd + " -i " + inputFile + ffmpeg_opts + proxyFile
        print("............RUNNING:  ", ffmpeg_run)
        p = subprocess.Popen(ffmpeg_run, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for line in p.stdout.readlines():
            # print(line)
            print(".", end = '')
        retval = p.wait()
        print("")

    print("...PROXIES CREATED ")

def mltLineParser(line):
    newline = line.replace("proxy_files/_proxy_", "")
    newline2 = newline.replace("_proxy_", "")
    return newline2

def convertMLTFile(MLTFile):
    print("...CONVERT MELT FILE")
    backupMLTFile = MLTFile[0:MLTFile.rfind(".")] + "_BACKUP.mlt"
    newMLTFile = MLTFile[0:MLTFile.rfind(".")] + "_NOPROXY.mlt"
    print("......Backing up: ", MLTFile, "to: ", backupMLTFile)
    shutil.copyfile(MLTFile, backupMLTFile, follow_symlinks=True)

    print("......Opening File For Reading: ", MLTFile)
    fin = open(MLTFile, "r")

    print("......Opening File For Writing: ", newMLTFile)
    fout = open(newMLTFile, "w+")

    print("......Copying data")

    fl = fin.readlines()
    for x in fl:
        #print(x, mltLineParser(x))
        fout.write(mltLineParser(x))

    print("......Closing Files")
    fin.close()
    fout.close()

    print("...MELT FILE CONVERTED")

def main_with_args(videoDirectory = ".", createProxiesBool = False, adjustMLTFileBool = False, MLTFile = ""):
    print("Shotcut Proxy Handling Script")
    if(createProxiesBool):
        createProxies(videoDirectory)
    if(adjustMLTFileBool):
        convertMLTFile(MLTFile)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Shotcut Proxy Editing Script')
    parser.add_argument('--videoDir', action='store', required=False, type=str,  help='Proxy Conversion - Input dir for full size videos')
    parser.add_argument('--mltFile', action='store', required=False, type=str, help='Shotcut MLT file - convert once finished editing')
    args = parser.parse_args()

    print("Shotcut Proxy Handling Script")

    if ((args.mltFile == None) and (args.videoDir == None)):
        print("INPUT REQUIRED")
    elif ((args.mltFile != None) and (args.videoDir != None)):
        print("CAN ONLY RUN ONE TASK!")
    elif(args.mltFile != None):
        mltfilename = str(args.mltFile)
        convertMLTFile(mltfilename)
    elif (args.videoDir != None):
        vidDirName = str(args.videoDir)
        createProxies(vidDirName)
