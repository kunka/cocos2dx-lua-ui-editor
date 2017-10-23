#!/usr/bin/env python
import os

project_root=os.sys.argv[1]
adb=os.sys.argv[2]
packageName=os.sys.argv[3]
defaultActivity=os.sys.argv[4]
android_dir=os.sys.argv[5]

print "mac project_root    = " + project_root
print "adb path            = " + adb
print "packageName         = " + packageName
print "defaultActivity     = " + defaultActivity
print "android_dir         = " + android_dir

os.chdir(project_root)

os.system("mkdir -p " + project_root + "/gen")
filePath = project_root +  "/gen/filelist.txt"
filePath_tmp = project_root +  "/gen/filelist_tmp.txt"

files={}
changedFiles={}
if os.path.exists(filePath):
    fin = open(filePath, 'r')
    lines = fin.readlines()
    fin.close()
    for line in lines:
        pos=line.find(' ')
        k=line[:pos]
        v=line[pos+1:]
        files[k]=v

whiteList = ["png", "jpg", "jpeg", "plist", "tmx", "tsx", "ttf", "fnt", "fsh", "vsh", "json", "mp3"]
append = ""
for k in whiteList:
    append = append + "|" + k

os.system("rm -f " + filePath_tmp)
os.system("find -E src -regex '.*\.(lua"+ append + ")' -exec md5 {} \;|awk '{print $2,$4}'|awk -F[\(\)] '{print $2$3}' >> " + filePath_tmp)
os.system("find -E res -regex '.*\.(lua"+ append + ")' -exec md5 {} \;|awk '{print $2,$4}'|awk -F[\(\)] '{print $2$3}' >> " + filePath_tmp)

fin = open(filePath_tmp, 'r')
lines = fin.readlines()
fin.close()
print("total files count   = " + str(len(lines)))
for line in lines:
    pos=line.find(' ')
    k=line[:pos]
    v=line[pos+1:]
    if (not (k in files) or files[k] != v):
        changedFiles[k]=v

os.system("mv " + filePath_tmp + " " + filePath)

os.system("find res -type d -exec " + adb + " shell mkdir -p " + android_dir + "/{} \;")
os.system("find src -type d -exec " + adb + " shell mkdir -p " + android_dir + "/{} \;")

for key, value in changedFiles.iteritems() :
#    print key
    os.system(adb + " push " + key + " " + android_dir + key)

print("changed files count = " + str(len(changedFiles)))
os.system(adb + " shell am force-stop " + packageName)
os.system(adb + " shell am start -n " + packageName + "/" + defaultActivity)
