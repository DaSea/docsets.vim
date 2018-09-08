# -*- coding: utf-8 -*-
#!/usr/bin/env python3

import os
import sqlite3
#  from tomd import Tomd
import html2text
import vim

# Manager docset
class DocsetManager(object):
    # "/media/entertainment/Doc/docsets"
    docsetpath=''
    # docsetsmap = {"cpp":"C++.docset", "c":"C.docset", "python":"Python_3.docset",
            #  "bash":"Bash.docset", "go":"Go.docset"}
    docsetsmap = {}
    # The exists docset handle map:"type":obj(Docset)
    dochandlemap = {}
    def __init__(self):
        pass
        #  self.docsetpath = docsetpath
        #  self.__getdocsetsmap(docsetpath)

    def __del__(self):
        self.dochandlemap.clear()

    def setAttr(self, docsetpath, docsetsmap):
        self.docsetpath = docsetpath
        self.docsetsmap = docsetsmap

    def hasExistDocsets(self, ftype):
        if ftype in self.docsetsmap:
            return True
        return False

    def openSearchResult(self, searchtype, searchpath):
        dochandle = self.__getHandle(searchtype)
        if not dochandle:
            return
        # open path and display in buffer
        results = dochandle.openSearchPath(searchpath)
        if results:
            self.__openResultBuffer()
            cb = vim.current.buffer
            #  print(cb.name)
            if cb.name.find("DocsetsWin") != -1:
                retlist = results.split('\n')
                filter(None, retlist)
                cb[:] = retlist

    def search(self, searchtype, searchname):
        results = self.__search(searchtype, searchname)
        if results:
            # fill result to buffer
            cb = vim.current.buffer
            #  cb.append(results)
            retlist = results.split('\n')
            filter(None, retlist)
            cb[:] = retlist

    def getSearchIndexList(self, ftype):
        """
        Get the function, macro and so on list in a docset!
        """
        if ftype not in self.docsetsmap:
            return None
        dochandle = self.__getHandle(ftype)
        return dochandle.getIndexList()

    def __search(self, searchtype, searchname):
        dochandle = self.__getHandle(searchtype)
        if dochandle:
            return dochandle.search(searchname)
        else:
            return ""

    def __getHandle(self, searchtype):
        dochandle=None
        if searchtype in self.dochandlemap:
            dochandle = self.dochandlemap[searchtype]
        else:
            dochandle = self.__createhandle(searchtype)
            if dochandle:
                self.dochandlemap[searchtype] = dochandle
        return dochandle

    def __createhandle(self, searchtype):
        if searchtype not in self.docsetsmap:
            return None
        dochandle = Docset(self.docsetpath, searchtype, self.docsetsmap[searchtype])
        return dochandle

    def __openResultBuffer(self):
        vim.eval("docsets#open_window()")
        # find buffer, open
        #  find = True
        #  for b in vim.buffers:
            #  if b.name=="DocsetsWin":
                #  vim.current.buffer = b
                #  find = True
                #  break

        #  if find:
            #  return vim.current.buffer
        #  # create buffer
        #  return None

    def __getdocsetsmap(self, docsetpath):
        for dirname in os.listdir(docsetpath):
            fulldocset = docsetpath + os.sep + dirname
            if os.path.isdir(fulldocset):
                docsetname = dirname[:dirname.find('.')]

class SearchIndex:
    name = ''
    utype = ''
    path = ''

    def __init__(self, name, utype, path):
        self.name = name
        self.utype = utype
        self.path = path

    def __str__(self):
        return "{0:30s} {1:20s} {2}".format(self.name, self.utype, self.path)

    def setAttr(self, name, utype, path):
        self.name = name
        self.utype = utype
        self.path = path

class Docset(object):
    typename=''
    connhandle=None # sqlite3 handle
    docsetpath='' # Docset path:/path/to/C.docset
    reallydocpath='' # /path//to/C.docset/Contents/Resources/Documents
    # 关于search index list的缓存
    searchIndex = []
    def __init__(self, path, typen, docsetdir):
        self.docsetpath = path + "/" + docsetdir
        self.reallydocpath = self.docsetpath + "/Contents/Resources/Documents/"
        self.typename = typen
        fulldbname = self.docsetpath + "/Contents/Resources/docSet.dsidx"
        self.connhandle = self.__createhandle(fulldbname)

    def __del__(self):
        #  print("Docset destructor!")
        if self.connhandle:
            self.connhandle.close()
        self.searchIndex.clear()

    def getIndexList(self):
        if self.searchIndex:
            return self.indexList()

        c = self.connhandle.cursor()
        execname = 'select name,type,path from searchIndex'
        cursor = c.execute(execname)
        #  indexlist = []
        self.searchIndex.clear()
        for row in cursor:
            self.searchIndex.append(SearchIndex(row[0], row[1], row[2]))
            #  item = "{0:100s} {1:100s} {2}".format(row[0], row[1], row[2])
            #  indexlist.append(item)
        return self.indexList()

    def indexList(self):
        indexlist = []
        for item in self.searchIndex:
            indexlist.append(str(item))
        return indexlist

    def search(self, content):
        c = self.connhandle.cursor()
        execname = 'select path from searchIndex where name like \"%%%s\"'%(content)
        cursor = c.execute(execname)
        searchpath = ''
        for row in cursor:
            searchpath = row[0]
        return self.openSearchPath(searchpath)

    def openSearchPath(self, searchpath):
        if not searchpath:
            return ''
        fulldcname = self.reallydocpath + searchpath
        #  print("fulldcname: %s"%(fulldcname))
        # get content
        fo = open(fulldcname, "r+")
        alllines = fo.read()
        markdown = self.__htmltotext(alllines)
        #  testWrite()
        fo.close()
        return markdown

    def __createhandle(self, fulldbname):
        if not os.path.exists(fulldbname):
            return None
        return sqlite3.connect(fulldbname)

    def __htmltotext(self, alllines):
        """
        this is not perfect, so ....!
        """
        h = html2text.HTML2Text()
        h.ignore_links = True
        h.ignore_image = True
        h.ignore_tables= True
        return h.handle(alllines)

#*****************************************************
# docsetManager is a singleton
#*****************************************************
docsetManager = DocsetManager()

__all__ = ['docsetManager']

